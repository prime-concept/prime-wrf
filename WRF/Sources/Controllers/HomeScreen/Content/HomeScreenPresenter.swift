import CoreLocation
import Foundation
import MapKit
import PromiseKit

protocol HomeScreenPresenterProtocol: AnyObject {
    func didLoad()

    func loadBanner()
    func loadRestaurants(withCityID cityID: String?)
    func loadNotifications()
    func loadMoreEvents(withCityID cityID: String?)

    func selectRestaurant(id: MapRestaurantViewModel.IDType)

    func didTransitionToNotifications()
    func didActivateSearchMode()

    func didToggleFavorite(eventId: Event.IDType, favorite: Bool)
    func didSelectEvent(id: Event.IDType)
}

final class HomeScreenPresenter: HomeScreenPresenterProtocol {
    private static let restaurantsCount = 999

    weak var viewController: HomeScreenViewControllerProtocol?

    private let restaurantsEndpoint: RestaurantsEndpointProtocol
    private let hostessScheduleEndpoint: HostessScheduleEndpointProtocol
    private let locationService: LocationServiceProtocol
    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let notificationEndpoint: PrimePassNotifyEndpointProtocol
    private let eventsEndpoint: EventsEndpointProtocol
    private let bannersEndpoint: BannersEndpointProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let authService: AuthServiceProtocol
    private let notificationPersistenceService: NotificationPersistenceServiceProtocol
    private let restaurantsPersistenceService: RestaurantsPersistenceServiceProtocol
    private let assessmentPersistenceService: AssessmentPersistenceServiceProtocol
    private let locationBasedNotificationsService: LocationBasedNotificationsServiceProtocol

    private var restaurants: [Restaurant] = []
    private var assessments: [PrimePassAssessment] = []
    private var loadedSchedules: [HostessListSchedule] = []

    private var events: [Event] = []
    private var eventPresentationManager: FloatingControllerPresentationManager? = nil
    private var nextEventsPage = 1
    private var mayLoadMoreEvents = true

    private var didLocationBasedNotificationsRegistered = false
    private let locationManager = CLLocationManager()

    init(
        restaurantsEndpoint: RestaurantsEndpointProtocol,
        hostessScheduleEndpoint: HostessScheduleEndpointProtocol,
        locationService: LocationServiceProtocol,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        notificationEndpoint: PrimePassNotifyEndpointProtocol,
        eventsEndpoint: EventsEndpointProtocol,
        bannersEndpoint: BannersEndpointProtocol,
        favoritesService: FavoritesServiceProtocol,
        authService: AuthServiceProtocol,
        notificationPersistenceService: NotificationPersistenceServiceProtocol,
        restaurantsPersistenceService: RestaurantsPersistenceService,
        assessmentPersistenceService: AssessmentPersistenceServiceProtocol,
        locationBasedNotificationsService: LocationBasedNotificationsServiceProtocol
    ) {
        self.restaurantsEndpoint = restaurantsEndpoint
        self.hostessScheduleEndpoint = hostessScheduleEndpoint
        self.locationService = locationService
        self.feedbackEndpoint = feedbackEndpoint
        self.notificationEndpoint = notificationEndpoint
        self.authService = authService
        self.notificationPersistenceService = notificationPersistenceService
        self.eventsEndpoint = eventsEndpoint
        self.bannersEndpoint = bannersEndpoint
        self.favoritesService = favoritesService
        self.restaurantsPersistenceService = restaurantsPersistenceService
        self.assessmentPersistenceService = assessmentPersistenceService
        self.locationBasedNotificationsService = locationBasedNotificationsService

        registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func didLoad() {
        loadBanner()
        reloadEvents()
        loadRestaurants()
        loadNotifications()
    }

    func loadNotifications() {
        guard let userID = authService.authorizationData?.userID else {
            viewController?.setNotificationsButton(hidden: true, count: 0)
            return
        }

        DispatchQueue.main.async {
            self.viewController?.setNotificationsButton(hidden: false, count: 0)
        }

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.notificationPersistenceService.retrieve()
        }.then(on: queue) { savedNotifications -> Promise<([PrimePassNotification], [PrimePassNotification])> in
            self.notificationEndpoint.retrieve(userID: userID).result.map { response in
                (savedNotifications, response.data ?? [])
            }
        }.done(on: queue) { savedNotifications, serverNotifications in
            self.notificationPersistenceService.save(notifications: serverNotifications)

            let newNotificationCount = max(0, serverNotifications.count - savedNotifications.count)
            DispatchQueue.main.async {
                self.viewController?.setNotificationsButton(hidden: false, count: newNotificationCount)
            }
        }.catch { error in
            print("HomeScreen presenter: error fetching notifications \(error.localizedDescription)")
        }
    }

    private func reloadEvents() {
        events = []
        nextEventsPage = 1
        loadMoreEvents()
    }

    func loadMoreEvents(withCityID cityID: String? = nil) {
        guard mayLoadMoreEvents else {
            return
        }

        mayLoadMoreEvents = false

        eventsEndpoint
            .retrieve(
                page: nextEventsPage,
                title: nil,
                tag: nil,
                date: nil,
                cityID: cityID
            )
            .result
            .done { [weak self] eventsResponse in
                guard let self else { return }
                mayLoadMoreEvents = true
                guard !eventsResponse.items.isEmpty else { return }
                events += eventsResponse.items
                updateEventsCarousel(with: events)
                nextEventsPage += 1
            }.catch { error in
                print("loadEvents error: \(error)")
                self.mayLoadMoreEvents = true
            }
    }

    private func updateEventsCarousel(with events: [Event]) {
        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "dd MMM HH:dd"

        let viewModels: [EventCellViewModel] = events.map { event in
            var dateString: String?
            if let date = event.schedule.first {
                dateString = formatter.string(from: date)
            }

            return EventCellViewModel(
                id: event.id,
                imageURL: event.images?.first?.image,
                date: dateString,
                title: event.title,
                subtitle: event.description,
                isFavorite: event.isFavorite
            )
        }

        viewController?.set(events: viewModels)
    }

    @objc
    private func eventFavoriteToggled(notification: Notification) {
        guard let eventId = FavoritesService.extractEventFavorite(from: notification) else {
            return
        }

        let isFavorite = notification.name == .resourceFavorited
        events = events.map { event in
            if event.id != eventId { return event }
            var event = event
            event.isFavorite = isFavorite
            return event
        }
        updateEventsCarousel(with: events)
    }

    func selectRestaurant(id: MapRestaurantViewModel.IDType) {
        guard let restaurant = restaurants[safe: id] else {
            return
        }

        AnalyticsReportingService.shared.didTransitionToRestaurantCard(id: restaurant.id,
                                                                       name: restaurant.title)
        viewController?.present(
            restaurant: restaurant,
            assessment: assessments.first { $0.place == restaurant.primePassID }
        )
    }
    
    func didTransitionToNotifications() {
        AnalyticsReportingService.shared.didTransitionToNotifications()
    }
    
    func didActivateSearchMode() {
        AnalyticsReportingService.shared.didActivateSearchMode()
    }

    func didToggleFavorite(eventId: Event.IDType, favorite: Bool) {
        let action: () -> Void = { [weak self] in
            self?.favoritesService.updateFavoritesStatus(
                resourceID: eventId,
                type: .events,
                isFavorite: !favorite
            ).cauterize()
        }

        if authService.isAuthorized {
            action()
            return
        }

        viewController?.handleUnauthorizedUser(completion: action)
    }

    func didSelectEvent(id: Event.IDType) {
        let event = events.first { $0.id == id }

        guard let event, let viewController else { return }

        let eventAssembly = EventAssembly(event: event)
        let eventPresentationManager = FloatingControllerPresentationManager(
            context: .event,
            groupID: EventsViewController.floatingControllerGroupID,
            sourceViewController: viewController,
            grabberAppearance: .light
        )

        eventPresentationManager.contentViewController = eventAssembly.makeModule()
        eventPresentationManager.present()

        if let trackedScrollView = eventAssembly.trackedScrollView {
            eventPresentationManager.track(scrollView: trackedScrollView)
        }

        self.eventPresentationManager = eventPresentationManager
    }

    func loadBanner() {
        //Set empty banner until reviving response.
        if let url = URL(string: "example.com") {
             viewController?.set(banner: BannerViewModel(
                    imageURL: url,
                    buttonTitle: ""
                ){})
        }

        bannersEndpoint.retrieve().result.done { [weak self] response in
            guard let self else { return }

            self.viewController?.hideLoading()
            let banner = response.items.first

            guard
                let banner,
                let imageURL = banner.images.first?.imageURL,
                let actionURL = URL(string: banner.link)
            else {
                viewController?.set(banner: nil)
                return
            }
            
            let viewModel = BannerViewModel(
                imageURL: imageURL,
                buttonTitle: banner.buttonTitle
            ) {
                UIApplication.shared.open(actionURL) { success in
                    if !success {
                        print("Failed to open the action URL \(actionURL.absoluteString)")
                    }
                }
            }
            viewController?.set(banner: viewModel)
        }.catch { error in
            print(error)
        }
    }

    func loadRestaurants(withCityID cityID: String? = nil) {
        viewController?.showLoading()

        let location = locationService.lastLocation?.coordinate
        loadCachedRestaurants(location: location)

        locationService.fetchLocation { [weak self] result in
            var location: CLLocationCoordinate2D? = nil

            if case .success(let fetchedLocation) = result {
                location = fetchedLocation
            }

            self?.loadRestauraunts(location, cityID)
        }
    }

    private func loadRestauraunts(_ coordinates: CLLocationCoordinate2D?, _ cityID: String? = nil) {
        typealias RestaurantsInfo = ([Restaurant], [HostessListSchedule], [PrimePassAssessment])

        /// Get list of restaurants
        let promise = self.restaurantsEndpoint.retrieve(
            tag: nil,
            location: coordinates,
            cityID: cityID,
            tags: [],
            page: 1,
            perPage: HomeScreenPresenter.restaurantsCount
        ).result

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue
            .promise { promise }
            /// Get schedules list by restaurants hostess schedule keys
            .then { restaurants -> Promise<RestaurantsInfo> in
                self.restaurants = restaurants.items

                let hostessScheduleKeys: [String] = restaurants.items.compactMap {
                    guard !$0.hostessScheduleKey.isEmpty else { return nil }
                    return $0.hostessScheduleKey
                }
                let schedulePromise: Promise<HostessResponse<[HostessListSchedule]>> =
                self.hostessScheduleEndpoint.schedules(for: hostessScheduleKeys, date: Date()).result

                return when(resolved: schedulePromise)
                    .map { response in
                        return (restaurants.items, {
                            guard let result = response.first else { return [] }
                            switch result {
                            case .fulfilled(let response):
                                return response.data ?? []
                            case .rejected(let error):
                                print(error)
                                return []
                            @unknown default:
                                return []
                            }
                        }(), [])
                    }
                    .recover { _ in
                        Guarantee<RestaurantsInfo>.value((restaurants.items, [], []))
                    }
            }
            /// Get assessments list by restaurants primePassIDs
            .then(on: queue) { (restaurants, schedules, assessments) -> Promise<RestaurantsInfo> in
                let promises: [Promise<PrimePassArrayResponse<PrimePassAssessment>>] = restaurants
                    .compactMap {
                        if $0.primePassID.isEmpty {
                            return nil
                        }

                        return self.feedbackEndpoint.retrieveAssessment(place: $0.primePassID).result
                    }
                return when(fulfilled: promises)
                    .map { (restaurants, schedules, $0.compactMap({ $0.data?.first })) }
                    .recover { _ -> Guarantee<RestaurantsInfo> in
                        Guarantee.value((restaurants, schedules, []))
                    }
            }
        .then(on: queue) { result -> Promise<RestaurantsInfo> in
            let (restaurants, schedules, assessments) = result
            self.restaurants = restaurants
            self.loadedSchedules = schedules
            self.assessments = assessments
            return self.saveRestaurants(restaurants: restaurants, assessments: assessments).map { result }
        }
        .done { restaurants, schedules, assessments in
            self.show(
                restaurants: restaurants,
                schedules: schedules,
                assessments: assessments,
                location: coordinates
            )
            self.viewController?.hideLoading()
        }
        .catch { error in
            print("HomeScreen presenter: error while retrieving restaurants = \(error.localizedDescription)")
            self.viewController?.hideLoading()
            self.viewController?.showSystemAlert(
                .init(
                    title: "Ошибка при получении данных",
                    actions: [
                        .init(
                            title: "Повторить",
                            style: .default,
                            handler: { _ in
                                self.loadRestaurants()
                            }),
                        .init(title: "Отмена", style: .cancel)
                    ]
                )
            )
        }
    }

    // MARK: - Private API
    
    private func sendEventFromAdvancedFilterForAnalytics(filterTags: [TypedTag]) {
        var submittingFiltersDict = [TagType: [String]]()
        
        struct SubmittingFilterItem: Encodable {
            var type: TagType
            var tagTitle: [String]
        }
        
        //Creating new dict with unique type and titles list in value
        for filterItem in filterTags {
            if var chosenItemTitles = submittingFiltersDict[filterItem.type] {
                chosenItemTitles.append(filterItem.tag.title)
                submittingFiltersDict[filterItem.type] = chosenItemTitles
            } else {
                submittingFiltersDict[filterItem.type] = [filterItem.tag.title]
            }
        }
        
        let uniqueTypedTags = submittingFiltersDict.map { (type, title) in
            SubmittingFilterItem(type: type, tagTitle: title)
        }
        
        do {
            let submittingFilterItems = try uniqueTypedTags.toJSONString()
            AnalyticsReportingService.shared.didFilterByAdvancedFilter(items: submittingFilterItems)
        } catch {
            print("Error converting to JSON: \(error)")
        }
    }

    private func loadCachedRestaurants(location: CLLocationCoordinate2D?) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let promise = restaurantsPersistenceService.retrieve()

        queue.promise {
            when(fulfilled: promise, self.assessmentPersistenceService.retrieve())
        }.done { restaurants, assessments in
            guard !restaurants.isEmpty, !assessments.isEmpty else {
                return
            }
            self.restaurants = restaurants
            self.assessments = assessments

            self.show(
                restaurants: restaurants,
                schedules: [],
                assessments: assessments,
                location: location
            )
        }.cauterize()
    }

    private func saveRestaurants(
        restaurants: [Restaurant],
        assessments: [PrimePassAssessment]
    ) -> Promise<Void> {
        return when(
            fulfilled:
            restaurantsPersistenceService.save(restaurants: restaurants),
            assessmentPersistenceService.save(assessments: assessments)
        )
    }

    private func show(
        restaurants: [Restaurant],
        schedules: [HostessListSchedule],
        assessments: [PrimePassAssessment],
        location: CLLocationCoordinate2D?
    ) {
        viewController?.set(
            restaurants: restaurants.enumerated().compactMap { (offset, element) in
                let schedule = schedules.first{ "\($0.restaurantID)" == element.primePassID }
                let assessment = assessments.first(where: { $0.place == element.primePassID })
                return makeViewModel(
                    id: offset,
                    restaurant: element,
                    schedule: schedule,
                    assessment: assessment,
                    location: location
                )
            }
        )
        viewController?.hideLoading()
    }

    @objc
    private func userDidLogin() {
        DispatchQueue.main.async {
            self.viewController?.setNotificationsButton(hidden: false, count: 0)
        }

        reloadEvents()
        loadRestaurants()
        loadNotifications()
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDidLogin),
            name: .login,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eventFavoriteToggled),
            name: .resourceFavorited,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(eventFavoriteToggled),
            name: .resourceUnfavorited,
            object: nil
        )
    }

    private func makeViewModel(
        id: Int,
        restaurant: Restaurant,
        schedule: HostessListSchedule?,
        assessment: PrimePassAssessment?,
        location: CLLocationCoordinate2D?
    ) -> MapRestaurantViewModel {
        var distanceText: String?
        if let location = location, let coordinates = restaurant.coordinates {
            let from = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let to = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

            let distance = to.distance(from: from)
            distanceText = FormatterHelper.distanceRepresentation(distanceInMeters: distance)
        }

        let scheduleLength = 6
        let schedules: [String] = {
            guard
                restaurant.canBookOnline == true,
                let timeDatas = schedule?.eligibleTimeData()
            else { return [] }
            return Array(timeDatas.prefix(scheduleLength))
        }()

        return MapRestaurantViewModel(
            id: id,
            title: restaurant.title,
            address: nil,
            location: restaurant.coordinates?.coordinate,
            distanceText: distanceText,
            imageURL: restaurant.images.first?.image,
            schedule: Array(schedules),
            rating: Int(assessment?.rating ?? 0),
            assessmentsCountText: FormatterHelper.assessments(assessment?.number ?? 0),
            price: restaurant.price,
            deliveryTime: restaurant.deliveryTime,
            hasDelivery: (restaurant.deliveryLink?.count ?? 0) > 0,
            isClosed: restaurant.isClosed ?? false,
            logoURL: restaurant.logos?.first?.image
        )
    }
}
