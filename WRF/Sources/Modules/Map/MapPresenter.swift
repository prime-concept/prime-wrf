import CoreLocation
import Foundation
import MapKit
import PromiseKit

extension Notification.Name {
    static let locationPermissionAcquired = Notification.Name("locationPermissionAcquired")
}

protocol MapPresenterProtocol: AnyObject {
    func loadTags()
    func loadRestaurants()
    func loadRestaurants(by tags: [TypedTag])
    func loadNotifications()

    func selectTag(id: MapTagViewModel.IDType)
    func selectRestaurant(id: MapRestaurantViewModel.IDType)
    func selectFilter()

    func handleCurrentLocationRequest()
    func didTransitionToNotifications()
    func didActivateSearchMode()
}

final class MapPresenter: MapPresenterProtocol {
    private static let restaurantsCount = 999
    private static let allRestaurantsTagID = "all_restaurants_tag_id"

    weak var viewController: MapViewControllerProtocol?

    private let restaurantsEndpoint: RestaurantsEndpointProtocol
    private let tagsEndpoint: TagsEndpointProtocol
    private let hostessScheduleEndpoint: HostessScheduleEndpointProtocol
    private let locationService: LocationServiceProtocol
    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let notificationEndpoint: PrimePassNotifyEndpointProtocol
    private let authService: AuthServiceProtocol
    private let notificationPersistenceService: NotificationPersistenceServiceProtocol
    private let tagsPersistenceService: TagPersistenceServiceProtocol
    private let restaurantsPersistenceService: RestaurantsPersistenceServiceProtocol
    private let assessmentPersistenceService: AssessmentPersistenceServiceProtocol
    private let tagContainerPersistenceService: TagContainerPersistenceServiceProtocol
    private let locationBasedNotificationsService: LocationBasedNotificationsServiceProtocol

    private var tags: [Tag] = []
    private var restaurants: [Restaurant] = []
    private var assessments: [PrimePassAssessment] = []
    private var loadedSchedules: [HostessListSchedule] = []
    private var selectedTags: [TypedTag] = []

    private var didLocationBasedNotificationsRegistered = false
    private let locationManager = CLLocationManager()

    init(
        restaurantsEndpoint: RestaurantsEndpointProtocol,
        tagsEndpoint: TagsEndpointProtocol,
        hostessScheduleEndpoint: HostessScheduleEndpointProtocol,
        locationService: LocationServiceProtocol,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        notificationEndpoint: PrimePassNotifyEndpointProtocol,
        authService: AuthServiceProtocol,
        notificationPersistenceService: NotificationPersistenceServiceProtocol,
        tagsPersistenceService: TagPersistenceServiceProtocol,
        restaurantsPersistenceService: RestaurantsPersistenceService,
        assessmentPersistenceService: AssessmentPersistenceServiceProtocol,
        tagContainerPersistenceService: TagContainerPersistenceServiceProtocol,
        locationBasedNotificationsService: LocationBasedNotificationsServiceProtocol
    ) {
        self.restaurantsEndpoint = restaurantsEndpoint
        self.tagsEndpoint = tagsEndpoint
        self.hostessScheduleEndpoint = hostessScheduleEndpoint
        self.locationService = locationService
        self.feedbackEndpoint = feedbackEndpoint
        self.notificationEndpoint = notificationEndpoint
        self.authService = authService
        self.notificationPersistenceService = notificationPersistenceService
        self.tagsPersistenceService = tagsPersistenceService
        self.restaurantsPersistenceService = restaurantsPersistenceService
        self.assessmentPersistenceService = assessmentPersistenceService
        self.tagContainerPersistenceService = tagContainerPersistenceService
        self.locationBasedNotificationsService = locationBasedNotificationsService

        self.registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadTags() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.tagsPersistenceService.retrieve()
        }.done { tags in
            let tags = self.makeTagsWithAllTag(tags)
            self.tags = tags
            self.viewController?.set(tags: self.makeViewModels(from: tags))
        }.then(on: queue) {
            self.tagsEndpoint.retrieve().result
        }.then(on: queue) { tags in
            self.tagsPersistenceService.save(tags: tags.restaurants).map { tags.restaurants }
        }.done { tags in
            let tags = self.makeTagsWithAllTag(tags)
            self.tags = tags
            self.viewController?.set(tags: self.makeViewModels(from: tags))
        }.catch { error in
            print("map presenter: error while retrieving tags = \(error.localizedDescription)")
        }
    }

    func loadRestaurants() {
        self.retrieveRestaurants(tag: nil)
    }

    func loadRestaurants(by tags: [TypedTag]) {
        guard tags != self.selectedTags else { return }
        
        self.sendEventFromAdvancedFilterForAnalytics(filterTags: tags)
        
        self.selectedTags = tags
        self.viewController?.updateFilter(count: self.selectedTags.count)
        self.viewController?.deselectSelectedTag()
        
        self.retrieveRestaurants(tag: nil, tags: tags)
    }

    func loadNotifications() {
        guard let userID = self.authService.authorizationData?.userID else {
            return
        }
        DispatchQueue.main.async {
            self.viewController?.showNotificationButton()
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
                self.viewController?.updateNotification(count: newNotificationCount)
            }
        }.catch { error in
            print("map presenter: error fetching notifications \(error.localizedDescription)")
        }
    }

    func selectTag(id: MapTagViewModel.IDType) {
        guard let tag = self.tags[safe: id] else {
            return
        }
        
        AnalyticsReportingService.shared.didFilterByTopTag(id: tag.id)
        
        self.selectedTags = []
        self.viewController?.updateFilter(count: 0)

        self.retrieveRestaurants(tag: tag.id == MapPresenter.allRestaurantsTagID ? nil: tag)
    }

    func selectRestaurant(id: MapRestaurantViewModel.IDType) {
        guard let restaurant = self.restaurants[safe: id] else {
            return
        }

        AnalyticsReportingService.shared.didTransitionToRestaurantCard(id: restaurant.id,
                                                                       name: restaurant.title)
        self.viewController?.present(
            restaurant: restaurant,
            assessment: self.assessments.first { $0.place == restaurant.primePassID }
        )
    }

    func selectFilter() {
        AnalyticsReportingService.shared.didTransitionToFilters()
        self.viewController?.present(filterIDs: self.selectedTags.map { $0.tag.id })
    }

    func handleCurrentLocationRequest() {
        AnalyticsReportingService.shared.didShowUserLocation()
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            self.viewController?.showCurrentLocation()
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        default:
            self.viewController?.showLocationSettings()
        }
    }
    
    func didTransitionToNotifications() {
        AnalyticsReportingService.shared.didTransitionToNotifications()
    }
    
    func didActivateSearchMode() {
        AnalyticsReportingService.shared.didActivateSearchMode()
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
    
    private func retrieveRestaurants(tag: Tag?, tags: [TypedTag] = []) {
        let location = self.locationService.lastLocation?.coordinate
        self.loadCachedRestaurants(tag: tag, location: location)

		typealias RestaurantsInfo = ([Restaurant], [HostessListSchedule], [PrimePassAssessment])

        let group = DispatchGroup()
        let (promise, cancellation) = self.restaurantsEndpoint.retrieve(
            tag: tag?.id,
            location: location,
            cityID: nil,
            tags: tags,
            page: 1,
            perPage: MapPresenter.restaurantsCount
        )
        let queue = DispatchQueue.global(qos: .userInitiated)

        group.enter()
        queue.promise { promise }.then { restaurants -> Promise<RestaurantsInfo> in
            self.restaurants = restaurants.items

            let hostessScheduleKeys: [String] = restaurants.items.compactMap {
                if $0.hostessScheduleKey.isEmpty { return nil }
                return $0.hostessScheduleKey
            }
            let schedulePromise: Promise<HostessResponse<[HostessListSchedule]>> =
            self.hostessScheduleEndpoint
                .schedules(
                    for: hostessScheduleKeys,
                    date: Date()
                ).result
            
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
        }.then(on: queue) { (restaurants, schedules, assessments) -> Promise<RestaurantsInfo> in
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
        }.then(on: queue) { result -> Promise<RestaurantsInfo> in
            let (restaurants, schedules, assessments) = result
            self.restaurants = restaurants
            self.loadedSchedules = schedules
            self.assessments = assessments
            return self.saveRestaurants(tag: tag, restaurants: restaurants, assessments: assessments).map { result }
        }.done { restaurants, schedules, assessments in
            self.show(restaurants: restaurants, schedules: schedules, assessments: assessments, location: location)
        }.ensure {
            group.leave()
        }.catch { error in
            print("map presenter: error while retrieving restaurants = \(error.localizedDescription)")
        }

        // Fetch location & load again if needed
        guard location == nil,
              [.authorizedWhenInUse, .authorizedAlways].contains(CLLocationManager.authorizationStatus()) else {
            return
        }

        self.registerLocationBasedNotificationsIfNeeded()
        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }

            // Load restaurants with location now and cancel previous request if not completed
            queue.promise {
                self.restaurantsEndpoint.retrieve(
                    tag: tag?.id,
                    location: location,
                    cityID: nil,
                    tags: tags,
                    page: 1,
                    perPage: MapPresenter.restaurantsCount
                ).result
            }.done { restaurants in
                cancellation()

                // Wait for request w/o location will finish
                group.notify(queue: .main) {
                    self.restaurants = restaurants.items
                    self.show(
                        restaurants: restaurants.items,
                        schedules: self.loadedSchedules,
                        assessments: self.assessments,
                        location: location
                    )
                }
            }.catch { error in
                print("map presenter: error while retrieving restaurants = \(error.localizedDescription)")
            }
        }
    }

    private func loadCachedRestaurants(tag: Tag?, location: CLLocationCoordinate2D?) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        let promise = tag == nil ?
            self.restaurantsPersistenceService.retrieve() :
            self.restaurantsPersistenceService.retrieveBy(tagID: tag?.id ?? "")
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
        tag: Tag?,
        restaurants: [Restaurant],
        assessments: [PrimePassAssessment]
    ) -> Promise<Void> {
        let promise: Promise<Void> = {
            guard let tag = tag else {
                return Promise.init()
            }
            let container = TagContainer(tagID: tag.id, restaurantIDs: restaurants.map { $0.id })
            return self.tagContainerPersistenceService.save(container: container)
        }()

        return when(
            fulfilled:
            self.restaurantsPersistenceService.save(restaurants: restaurants),
            self.assessmentPersistenceService.save(assessments: assessments),
            promise
        )
    }

    private func show(
        restaurants: [Restaurant],
        schedules: [HostessListSchedule],
        assessments: [PrimePassAssessment],
        location: CLLocationCoordinate2D?
    ) {
        self.viewController?.set(
            restaurants: restaurants.enumerated().compactMap { (offset, element) in
				let schedule = schedules.first{ "\($0.restaurantID)" == element.primePassID }
                let assessment = assessments.first(where: { $0.place == element.primePassID })
                return self.makeViewModel(
                    id: offset,
                    restaurant: element,
                    schedule: schedule,
                    assessment: assessment,
                    location: location
                )
            }
        )
    }

    @objc
    private func updateRestaurantsWithLocation() {
        self.registerLocationBasedNotificationsIfNeeded()
        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }

            DispatchQueue.main.async {
                self.viewController?.set(myLocationEnabled: true)
            }

            DispatchQueue.global(qos: .userInitiated).promise {
                self.restaurantsEndpoint.retrieve(
                    tag: nil,
                    location: location,
                    cityID: nil,
                    tags: [],
                    page: 1,
                    perPage: MapPresenter.restaurantsCount
                ).result
            }.done { restaurants in
                self.restaurants = restaurants.items
                self.show(
                    restaurants: restaurants.items,
                    schedules: self.loadedSchedules,
                    assessments: self.assessments,
                    location: location
                )
            }.catch { error in
                print("map presenter: error while retrieving restaurants = \(error.localizedDescription)")
            }
        }
    }

    @objc
    private func userDidLogin() {
        DispatchQueue.main.async {
            self.viewController?.showNotificationButton()
        }

        self.loadNotifications()
        self.retrieveRestaurants(tag: nil)
    }

    @objc
    private func checkLocationStatus() {
        self.registerLocationBasedNotificationsIfNeeded()
        self.locationService.fetchLocation { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.viewController?.set(myLocationEnabled: true)
                } else {
                    self.viewController?.set(myLocationEnabled: false)
                }
            }
        }
    }

    private func makeViewModels(from tags: [Tag]) -> [MapTagViewModel] {
        return tags.enumerated().compactMap {
            self.makeViewModel(id: $0.offset, tag: $0.element)
        }
    }

    private func makeTagsWithAllTag(_ tags: [Tag]) -> [Tag] {
        let totalCount = tags.compactMap { $0.count }.reduce(0, +)
        let allTag = self.makeAllRestaurantsTag(count: totalCount)
        return [allTag] + tags
    }

    private func makeAllRestaurantsTag(count: Int) -> Tag {
        /*
         Because Asset images are compiled, we need to store tag image in Bundle,
         so that we could get its URL at runtime
         */
        //swiftlint:disable:next force_unwrapping
        let imageUrl = Bundle.main.url(forResource: "restaurant-all-tag-image", withExtension: "png")!
        return Tag(
            id: MapPresenter.allRestaurantsTagID,
            title: "Все",
            images: [GradientImage(image: imageUrl)],
            count: count
        )
    }

    private func registerLocationBasedNotificationsIfNeeded() {
        guard !self.didLocationBasedNotificationsRegistered else {
            return
        }

        self.locationBasedNotificationsService.setup()

        self.didLocationBasedNotificationsRegistered = true
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateRestaurantsWithLocation),
            name: .locationPermissionAcquired,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.checkLocationStatus),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.userDidLogin),
            name: .login,
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
        let schedules = schedule?.eligibleTimeData().prefix(scheduleLength) ?? []

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

    private func makeViewModel(id: Int, tag: Tag) -> MapTagViewModel {
        return MapTagViewModel(
            id: id,
            title: tag.title,
            imageURL: tag.images?.first?.image,
            count: tag.count ?? 0
        )
    }
}
