import CoreLocation
import MapKit
import PromiseKit

protocol FavoritesPresenterProtocol: AnyObject {
    func loadFavorites()
    func loadFavorites(type: FavoriteType)
    func loadNextEvents()
    func loadNextRestaurants()

    func update(event model: FavoritesEventViewModel)
    func update(restaurant model: FavoritesRestaurantViewModel)

    func select(restaurant index: FavoritesRestaurantViewModel.IDType)
    func select(event index: FavoritesEventViewModel.IDType)
}

//swiftlint:disable file_length
final class FavoritesPresenter: FavoritesPresenterProtocol {
    weak var viewController: FavoritesViewControllerProtocol?

    private let favoritesEndpoint: FavoritesEndpointProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let eventEndpoint: EventEndpointProtocol
    private let restaurantEndpoint: RestaurantEndpointProtocol
    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let locationService: LocationServiceProtocol

    private let dateFormatter: DateFormatter

    private var restaurants: [Restaurant] = []
    private var events: [Event] = []

    private var pageable: Meta?

    private var assessments: [PrimePassAssessment] = []

    private var eventsResponse: NavigatorListResponse<Event>?

    private var currentlyShownType: FavoriteType = .restaurants
    private var lastLocation: CLLocation?
    private var isLoading = false

    init(
        favoritesEndpoint: FavoritesEndpointProtocol,
        favoritesService: FavoritesServiceProtocol,
        eventEndpoint: EventEndpointProtocol,
        restaurantEndpoint: RestaurantEndpointProtocol,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.favoritesEndpoint = favoritesEndpoint
        self.favoritesService = favoritesService
        self.eventEndpoint = eventEndpoint
        self.restaurantEndpoint = restaurantEndpoint
        self.feedbackEndpoint = feedbackEndpoint
        self.locationService = locationService

        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "dd MMM HH:dd"
        self.dateFormatter = formatter

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resourceFavorited),
            name: .resourceFavorited,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resourceUnfavorited),
            name: .resourceUnfavorited,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    func loadFavorites() {
        self.loadRestaurantsAndEvents()
    }

    func loadFavorites(type: FavoriteType) {
        self.currentlyShownType = type

        switch type {
        case .restaurants:
            self.loadRestaurants(page: 1)
        case .events:
            self.loadEvents(page: 1)
        default:
            break
        }
    }

    func loadNextEvents() {
        guard let pageable = self.pageable, pageable.hasNext, !self.isLoading else {
            return
        }
        self.isLoading = true
        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesEndpoint.retrieveEvents(page: pageable.page).result
        }.done { response in
            self.eventsResponse = response
            self.pageable = response.pageable
            self.events.append(contentsOf: response.items)

            let events = self.makeViewModels(
                events: response.items,
                restaurants: self.eventsResponse?.dependencies.restaurants ?? []
            )
            self.viewController?.append(events: events)
        }.ensure {
            self.isLoading = false
        }.catch { error in
            print("events presenter: error while loading events = \(error)")
        }
    }

    func loadNextRestaurants() {
        guard let pageable = self.pageable, pageable.hasNext, !self.isLoading else {
            return
        }
        self.isLoading = true
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.favoritesEndpoint.retrieveRestaurants(page: pageable.next).result
        }.then(on: queue) { response -> Promise<([Restaurant], [PrimePassAssessment])> in
            self.pageable = response.pageable
            self.restaurants.append(contentsOf: response.items)

            let promises: [Promise<PrimePassArrayResponse<PrimePassAssessment>>] = response.items.compactMap {
                if $0.primePassID.isEmpty {
                    return nil
                }

                return self.feedbackEndpoint.retrieveAssessment(place: $0.primePassID).result
            }
            return when(fulfilled: promises).map { (response.items, $0.compactMap { $0.data?.first }) }
        }.done { restaurants, assessments in
            self.assessments.append(contentsOf: assessments)

            let restaurants = self.makeViewModels(
                restaurants: restaurants,
                loadedAssessments: assessments
            )
            self.viewController?.append(restaurants: restaurants)
        }.ensure {
            self.isLoading = false
        }.catch { error in
            print("favorites presenter: error when loading favorites = \(error)")
        }
    }

    func update(event model: FavoritesEventViewModel) {
        guard let event = self.findEvent(by: model.id) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesService.updateFavoritesStatus(
                resourceID: event.id,
                type: model.type,
                isFavorite: model.isFavorite
            )
        }.catch { error in
            print("favorites presenter: error when executing favorite status change = \(error)")
        }
    }

    func update(restaurant model: FavoritesRestaurantViewModel) {
        guard let restaurant = self.findRestaurant(by: model.id) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesService.updateFavoritesStatus(
                resourceID: restaurant.id,
                type: model.type,
                isFavorite: model.isFavorite
            )
        }.catch { error in
            print("favorites presenter: error when executing favorite status change = \(error)")
        }
    }

    func select(restaurant index: FavoritesRestaurantViewModel.IDType) {
        guard let restaurant = self.findRestaurant(by: index), !restaurant.id.isEmpty else {
            print("Restaurant id is empty")
            viewController?.showSystemAlert(
                .init(
                    title: "Ошибка",
                    message: "Идентификатор ресторана не найден",
                    actions: [.init(title: "Ок")]
                )
            )
            return
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.feedbackEndpoint.retrieveAssessment(place: restaurant.id).result
        }.done { response in
            guard let assessments = response.data else {
                self.viewController?.show(restaurant: restaurant, assessment: nil)
                return
            }
            let assessment = assessments.first(where: { $0.place == restaurant.id })
            self.viewController?.show(restaurant: restaurant, assessment: assessment)
        }.catch { error in
            print("favorites presenter: error retrieving restaurant assessment = \(error)")
            // show in any case
            self.viewController?.show(restaurant: restaurant, assessment: nil)
        }
    }

    func select(event index: FavoritesEventViewModel.IDType) {
        guard let event = self.findEvent(by: index) else {
            return
        }
        self.viewController?.show(event: event)
    }

    // MARK: - Private API

    private func loadRestaurantsAndEvents() {
        let lastLocation = self.locationService.lastLocation?.coordinate
        if let location = lastLocation {
            self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }

        self.isLoading = true

        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        var loadedAssessments: [PrimePassAssessment] = []

        group.enter()
        queue.promise {
            when(
                fulfilled: self.favoritesEndpoint.retrieveRestaurants(page: 1).result,
                self.favoritesEndpoint.retrieveEvents(page: 1).result
            )
        }.then(on: queue) { response -> Promise<([Restaurant], [Event])> in
            let eventsResponse = response.1
            let restaurantsResponse = response.0

            if !eventsResponse.items.isEmpty {
                self.pageable = eventsResponse.pageable
                self.events = eventsResponse.items
            }

            if !restaurantsResponse.items.isEmpty {
                self.pageable = restaurantsResponse.pageable
                self.restaurants = restaurantsResponse.items
            }

            return Promise { $0.fulfill((restaurantsResponse.items, eventsResponse.items)) }
        }.then(on: queue) { restaurants, events -> Promise<([Restaurant], [Event], [PrimePassAssessment])> in
            let promises: [Promise<PrimePassArrayResponse<PrimePassAssessment>>] = restaurants.compactMap {
                if $0.primePassID.isEmpty {
                    return nil
                }

                return self.feedbackEndpoint.retrieveAssessment(place: $0.primePassID).result
            }
            return when(fulfilled: promises).map { (restaurants, events, $0.compactMap({ $0.data?.first })) }
        }.done { restaurants, events, assessments in
            self.assessments = assessments
            loadedAssessments = assessments

            if !restaurants.isEmpty {
                let restaurants = self.makeViewModels(
                    restaurants: restaurants,
                    loadedAssessments: assessments
                )
                self.viewController?.set(restaurants: restaurants)
            } else {
                let events = self.makeViewModels(
                    events: events,
                    restaurants: self.eventsResponse?.dependencies.restaurants ?? []
                )
                self.viewController?.set(events: events)
            }
        }.ensure {
            self.isLoading = false
            group.leave()
        }.catch { error in
            print("favorites presenter: error when loading favorites = \(error)")
        }

        guard lastLocation == nil else {
            return
        }

        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }
            self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            group.notify(queue: .main) {
                if !self.restaurants.isEmpty {
                    let restaurants = self.makeViewModels(
                        restaurants: self.restaurants,
                        loadedAssessments: loadedAssessments
                    )
                    self.viewController?.set(restaurants: restaurants)
                } else {
                    let events = self.makeViewModels(
                        events: self.events,
                        restaurants: self.eventsResponse?.dependencies.restaurants ?? []
                    )
                    self.viewController?.set(events: events)
                }
            }
        }
    }

    private func loadEvents(page: Int) {
        let lastLocation = self.locationService.lastLocation?.coordinate
        if let location = lastLocation {
            self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }

        self.isLoading = true

        let group = DispatchGroup()

        group.enter()
        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesEndpoint.retrieveEvents(page: page).result
        }.done { response in
            self.eventsResponse = response
            self.pageable = response.pageable
            self.events = response.items

            let events = self.makeViewModels(
                events: response.items,
                restaurants: self.eventsResponse?.dependencies.restaurants ?? []
            )
            self.viewController?.set(events: events)
        }.ensure {
            self.isLoading = false
            group.leave()
        }.catch { error in
            print("favorites presenter: error when loading favorites = \(error)")
        }

        guard lastLocation == nil else {
            return
        }

        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }
            self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            group.notify(queue: .main) {
                let events = self.makeViewModels(
                    events: self.events,
                    restaurants: self.eventsResponse?.dependencies.restaurants ?? []
                )
                self.viewController?.set(events: events)
            }
        }
    }

    private func loadRestaurants(page: Int) {
        let lastLocation = self.locationService.lastLocation?.coordinate
        if let location = lastLocation {
            self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }

        self.isLoading = true

        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        var loadedAssessments: [PrimePassAssessment] = []

        group.enter()
        queue.promise {
            self.favoritesEndpoint.retrieveRestaurants(page: page).result
        }.then { response -> Promise<([Restaurant], [PrimePassAssessment])> in
            self.pageable = response.pageable
            self.restaurants = response.items

            let promises: [Promise<PrimePassArrayResponse<PrimePassAssessment>>] = response.items.compactMap {
                if $0.primePassID.isEmpty {
                    return nil
                }

                return self.feedbackEndpoint.retrieveAssessment(place: $0.primePassID).result
            }
            return when(fulfilled: promises).map { (response.items, $0.compactMap({ $0.data?.first })) }
        }.done { restaurants, assessments in
            self.assessments = assessments
            loadedAssessments = assessments

            let restaurants = self.makeViewModels(
                restaurants: restaurants,
                loadedAssessments: assessments
            )
            self.viewController?.set(restaurants: restaurants)
        }.ensure {
            self.isLoading = false
            group.leave()
        }.catch { error in
            print("favorites presenter: error when loading favorites = \(error)")
        }

        guard lastLocation == nil else {
            return
        }

        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }
            self.lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            group.notify(queue: .main) {
                let restaurants = self.makeViewModels(
                    restaurants: self.restaurants,
                    loadedAssessments: loadedAssessments
                )
                self.viewController?.set(restaurants: restaurants)
            }
        }
    }

    private func loadEvent(id: Event.IDType) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.eventEndpoint.retrieve(id: id).result
        }.done { response in
            let event = response.item
            self.events.insert(event, at: 0)

            self.viewController?.append(
                event: self.makeViewModel(
                    index: event.id,
                    event: event,
                    location: self.lastLocation,
                    restaurants: self.eventsResponse?.dependencies.restaurants ?? [],
                    isFavorite: true
                )
            )
        }.catch { error in
            print("favorites presenter: error when loading event = \(error)")
        }
    }

    private func loadRestaurant(id: Restaurant.IDType) {
        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.restaurantEndpoint.retrieve(id: id).result
        }.then(on: queue) {
            response -> Promise<(Restaurant, [PrimePassAssessment])> in
            let restaurant = response.item

            if restaurant.primePassID.isEmpty {
                return Promise<(Restaurant, [PrimePassAssessment])>.value((restaurant, []))
            }

            return self.feedbackEndpoint.retrieveAssessment(place: restaurant.primePassID).result.map {
                (restaurant, $0.data ?? [])
            }
        }.done { restaurant, assessments in
            self.restaurants.insert(restaurant, at: 0)
            self.assessments.append(contentsOf: assessments)

            self.viewController?.append(
                restaurant: self.makeViewModel(
                    index: restaurant.id,
                    restaurant: restaurant,
                    location: self.lastLocation,
                    assessments: self.assessments,
                    isFavorite: true
                )
            )
        }.catch { error in
            print("favorites presenter: error when loading event = \(error)")
        }
    }

    private func findEvent(by id: Event.IDType) -> Event? {
        return self.events.first(where: { $0.id == id })
    }

    private func findRestaurant(by id: Restaurant.IDType) -> Restaurant? {
        return self.restaurants.first(where: { $0.id == id })
    }

    @objc
    private func resourceFavorited(notification: Notification) {
        guard let resourceId = notification.userInfo?["resourceID"] as? String,
              let type = notification.userInfo?["type"] as? FavoriteType,
              type == self.currentlyShownType else {
            return
        }
        switch self.currentlyShownType {
        case .events:
            if let (index, event) = self.events.enumerated().first(where: { $1.id == resourceId }) {
                events[index].isFavorite = true
                let model = self.makeViewModel(
                    index: event.id,
                    event: event,
                    location: self.lastLocation,
                    restaurants: self.eventsResponse?.dependencies.restaurants ?? [],
                    isFavorite: true
                )
                self.viewController?.set(index: index, event: model)
            } else {
                self.loadEvent(id: resourceId)
            }
        case .restaurants:
            if let (index, restaurant) = self.restaurants.enumerated().first(where: { $1.id == resourceId }) {
                restaurants[index].isFavorite = true
                let model = self.makeViewModel(
                    index: restaurant.id,
                    restaurant: restaurant,
                    location: self.lastLocation,
                    assessments: self.assessments,
                    isFavorite: true
                )
                self.viewController?.set(index: index, restaurant: model)
            } else {
                self.loadRestaurant(id: resourceId)
            }
        default:
            break
        }
    }

    @objc
    private func resourceUnfavorited(notification: Notification) {
        guard let resourceId = notification.userInfo?["resourceID"] as? String,
              let type = notification.userInfo?["type"] as? FavoriteType,
              type == self.currentlyShownType else {
            return
        }
        switch self.currentlyShownType {
        case .events:
            if let (index, event) = self.events.enumerated().first(where: { $1.id == resourceId }) {
                events[index].isFavorite = false
                let model = self.makeViewModel(
                    index: event.id,
                    event: event,
                    location: self.lastLocation,
                    restaurants: self.eventsResponse?.dependencies.restaurants ?? [],
                    isFavorite: false
                )
                self.viewController?.set(index: index, event: model)
            }
        case .restaurants:
            if let (index, restaurant) = self.restaurants.enumerated().first(where: { $1.id == resourceId }) {
                restaurants[index].isFavorite = false
                let model = self.makeViewModel(
                    index: restaurant.id,
                    restaurant: restaurant,
                    location: self.lastLocation,
                    assessments: self.assessments,
                    isFavorite: false
                )
                self.viewController?.set(index: index, restaurant: model)
            }
        default:
            break
        }
    }

    private func makeViewModel(
        index: Event.IDType,
        event: Event,
        location: CLLocation?,
        restaurants: [Restaurant],
        isFavorite: Bool
    ) -> [FavoritesEventViewModel] {
        var images: [GradientImage?] = event.images ?? []
        if images.isEmpty { images.append(nil) }

        var dateString: String?
        if let date = event.schedule.first {
            dateString = self.dateFormatter.string(from: date)
        }

        var nearestRestaurant: String?
        if let location = location {
            let restaurant = restaurants.filter {
                event.restaurantsIDs?.contains($0.id) ?? false
            }.min { (lhs, rhs) -> Bool in
                guard let leftLocation = lhs.coordinates?.location,
                      let rightLocation = rhs.coordinates?.location else {
                    return false
                }

                let lhsDistance = location.distance(from: leftLocation)
                let rhsDistance = location.distance(from: rightLocation)
                return lhsDistance < rhsDistance
            }
            nearestRestaurant = restaurant?.title
        }
        return images.map {
            FavoritesEventViewModel(
                id: index,
                title: event.title,
                description: event.description,
                bookingText: event.bookingText,
                isFavorite: isFavorite,
                date: dateString,
                nearestRestaurant: nearestRestaurant,
                imageURL: $0?.image
            )
        }
    }

    private func makeViewModel(
        index: Restaurant.IDType,
        restaurant: Restaurant,
        location: CLLocation?,
        assessments: [PrimePassAssessment],
        isFavorite: Bool
    ) -> FavoritesRestaurantViewModel {
        var distanceText: String?
        if let to = location, let coordinates = restaurant.coordinates {
            let distance = to.distance(from: coordinates.location)
            distanceText = FormatterHelper.distanceRepresentation(distanceInMeters: distance)
        }
        let assessment = assessments.first(where: { $0.place == restaurant.primePassID })
        return FavoritesRestaurantViewModel(
            id: index,
            title: restaurant.title,
            address: restaurant.address,
            description: restaurant.description,
            distanceText: distanceText,
            price: restaurant.price,
            rating: Int(assessment?.rating ?? 0),
            assessmentsCountText: FormatterHelper.assessments(assessment?.number ?? 0),
            coordinate: restaurant.coordinates,
            isFavorite: isFavorite,
            imageURL: restaurant.images.first?.image, 
            logoURL: restaurant.logos?.first?.image
        )
    }

    private func makeViewModels(
        restaurants: [Restaurant],
        loadedAssessments: [PrimePassAssessment]
    ) -> [FavoritesRestaurantViewModel] {
        return restaurants.compactMap {
            self.makeViewModel(
                index: $0.id,
                restaurant: $0,
                location: self.lastLocation,
                assessments: loadedAssessments,
                isFavorite: $0.isFavorite
            )
        }
    }

    private func makeViewModels(
        events: [Event],
        restaurants: [Restaurant]
    ) -> [[FavoritesEventViewModel]] {
        return events.compactMap {
            self.makeViewModel(
                index: $0.id,
                event: $0,
                location: self.lastLocation,
                restaurants: restaurants,
                isFavorite: $0.isFavorite
            )
        }
    }
}
