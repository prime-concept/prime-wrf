import CoreLocation
import PromiseKit
import UIKit

protocol SearchDeliveryPresenterProtocol {
    func loadRestaurants()
    func loadNextRestaurants()

    func select(restaurant id: SearchDeliveryViewModel.IDType)
}

final class SearchDeliveryPresenter: SearchDeliveryPresenterProtocol, SearchDeliveryChildModuleInput {
    weak var viewController: SearchDeliveryViewControllerProtocol?

    private let restaurantsEndpoint: RestaurantsEndpointProtocol
    private let restaurantEndpoint: RestaurantEndpointProtocol
    private let hostessScheduleEndpoint: HostessScheduleEndpointProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let locationService: LocationServiceProtocol

    private var pageable: Meta?
    private var assessments: [PrimePassAssessment] = []
    private var restaurants: [Restaurant] = []

    private var lastLocation: CLLocation?

    private var searchQuery: String?
    private var isLoading = false

    init(
        restaurantsEndpoint: RestaurantsEndpointProtocol,
        restaurantEndpoint: RestaurantEndpointProtocol,
        hostessScheduleEndpoint: HostessScheduleEndpointProtocol,
        favoritesService: FavoritesServiceProtocol,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.restaurantsEndpoint = restaurantsEndpoint
        self.restaurantEndpoint = restaurantEndpoint
        self.hostessScheduleEndpoint = hostessScheduleEndpoint
        self.favoritesService = favoritesService
        self.feedbackEndpoint = feedbackEndpoint
        self.locationService = locationService
    }

    // MARK: - Public API

    func loadRestaurants() {
        self.load(query: nil)
    }

    func load(query: String?) {
        self.isLoading = true
        self.searchQuery = query
        
        var lastLocation: CLLocation?
        if let coordinate = self.locationService.lastLocation?.coordinate {
            lastLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        self.lastLocation = lastLocation

        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        var loadedRestaurants: [Restaurant] = []
        var loadedAssessments: [PrimePassAssessment] = []
        var loadedSchedule: [HostessListSchedule] = []

        group.enter()
        queue.promise {
            self.loadRestaurants(page: 1, query: query)
        }.done { restaurants, schedule, assessments in
            loadedRestaurants = restaurants
            loadedAssessments = assessments
            loadedSchedule = schedule
            
            self.restaurants = restaurants
            self.assessments = assessments
            
            let restaurants = restaurants.enumerated().compactMap {
                index, restaurant -> SearchDeliveryViewModel in
                let assessment = assessments.first { $0.place == restaurant.primePassID }
                let schedule = schedule.first { "\($0.restaurantID)" == restaurant.primePassID }
                return self.makeViewModel(
                    index: index,
                    restaurant: restaurant,
                    location: lastLocation,
                    assessment: assessment,
                    isFavorite: restaurant.isFavorite,
                    schedule: schedule
                )
            }.filter { $0.hasDelivery }
            self.viewController?.set(restaurants: restaurants)
            self.viewController?.set(restaurantsCount: restaurants.count)
            self.viewController?.set(
                state: self.makeState(
                    itemCount: restaurants.count,
                    query: query ?? ""
                )
            )
        }.ensure {
            self.isLoading = false
            group.leave()
        }
        .catch { error in
            print("search restaurants presenter: error while loading restaurants = \(error.localizedDescription)")
        }

        guard lastLocation == nil else {
            return
        }

        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }
            lastLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.lastLocation = lastLocation
            group.notify(queue: .main) {
                self.viewController?.set(
                    restaurants: loadedRestaurants.enumerated().compactMap { (index, restaurant) in
                        let assessment = loadedAssessments.first { $0.place == restaurant.primePassID }
                        let schedule = loadedSchedule.first { "\($0.restaurantID)" == restaurant.primePassID }
                        return self.makeViewModel(
                            index: index,
                            restaurant: restaurant,
                            location: lastLocation,
                            assessment: assessment,
                            isFavorite: restaurant.isFavorite,
                            schedule: schedule
                        )
                    }.filter { $0.hasDelivery }
                )
                self.viewController?.set(
                    state: self.makeState(
                        itemCount: self.restaurants.count,
                        query: query ?? ""
                    )
                )
            }
        }
    }

    func loadNextRestaurants() {
        guard let pageable = self.pageable, pageable.hasNext, !self.isLoading else {
            return
        }
        let location = self.locationService.lastLocation
        
        self.isLoading = true
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.loadRestaurants(page: pageable.next, query: self.searchQuery)
        }.done { restaurants, schedules, assessments in
            self.restaurants.append(contentsOf: restaurants)
            self.assessments.append(contentsOf: assessments)
            
            let restaurants = restaurants.enumerated().compactMap {
                index, restaurant -> SearchDeliveryViewModel in
                let assessment = assessments.first { $0.place == restaurant.primePassID }
                let schedule = schedules.first(where: { "\($0.restaurantID)" == restaurant.primePassID })
                return self.makeViewModel(
                    index: index,
                    restaurant: restaurant,
                    location: location,
                    assessment: assessment,
                    isFavorite: restaurant.isFavorite,
                    schedule: schedule
                )
            }.filter { $0.hasDelivery }
            self.viewController?.append(restaurants: restaurants)
        }.ensure {
            self.isLoading = false
        }.catch { error in
            print("search restaurants presenter: error while loading restaurants = \(error.localizedDescription)")
        }
    }

    func select(restaurant id: SearchDeliveryViewModel.IDType) {
        if let restaurant = self.restaurants[safe: id] {
            self.viewController?.present(restaurant: restaurant)
        }
    }
}

// MARK: - Private API

private extension SearchDeliveryPresenter {

    func loadRestaurants(
        page: Int,
        query: String?
    ) -> Promise<([Restaurant], [HostessListSchedule], [PrimePassAssessment])> {
        let promise = self.restaurantsEndpoint.retrieve(page: page, title: query, tag: nil).result
        return promise.then { response -> Promise<([Restaurant], [HostessListSchedule])> in
            self.pageable = response.pageable
            let restaurants = response.items
            let hostessScheduleKeys: [String] = restaurants
                .compactMap {
                    guard !$0.hostessScheduleKey.isEmpty else { return nil }
                    return $0.hostessScheduleKey
                }
            let schedulePromise: Promise<HostessResponse<[HostessListSchedule]>> = self.hostessScheduleEndpoint.schedules(
                for: hostessScheduleKeys,
                date: Date()
            ).result
            return when(resolved: schedulePromise)
                .map { response in
                    let schedules: [HostessListSchedule] = {
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
                    }()
                    return (restaurants, schedules)
                }
                .recover { _ in Guarantee<([Restaurant], [HostessListSchedule])>.value((restaurants, [])) }
        }.then { restaurants, schedules -> Promise<([Restaurant], [HostessListSchedule], [PrimePassAssessment])> in
            let promises: [Promise<PrimePassArrayResponse<PrimePassAssessment>>] = restaurants
                .compactMap {
                    if $0.primePassID.isEmpty {
                        return nil
                    }
                    return self.feedbackEndpoint.retrieveAssessment(place: $0.primePassID).result
                }

            return when(fulfilled: promises)
                .map { (restaurants, schedules, $0.compactMap({ $0.data?.first })) }
                .recover { _ -> Guarantee<([Restaurant], [HostessListSchedule], [PrimePassAssessment])> in
                    Guarantee.value((restaurants, schedules, []))
                }
        }
    }

    func makeState(itemCount: Int, query: String) -> SearchDeliveryView.State {
        if itemCount == 0 && !query.isEmpty {
            return .querySearchIsEmpty
        }
        if itemCount == 0 {
            return .data(hasData: false)
        }
        return .data(hasData: itemCount != 0)
    }

    func makeViewModel(
        index: Int,
        restaurant: Restaurant,
        location: CLLocation?,
        assessment: PrimePassAssessment?,
        isFavorite: Bool,
        schedule: HostessListSchedule?
    ) -> SearchDeliveryViewModel {
        var distanceText: String?
        if let to = location, let coordinates = restaurant.coordinates {
            let distance = to.distance(from: coordinates.location)
            distanceText = FormatterHelper.distanceRepresentation(distanceInMeters: distance)
        }

        let scheduleLength = 5
        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "HH:mm"
        let schedules = ((schedule?.timeData ?? []))
            .filter { $0 > formatter.string(from: Date()) }.prefix(scheduleLength)

        return SearchDeliveryViewModel(
            id: index,
            title: restaurant.title,
            description: restaurant.description,
            coordinate: restaurant.coordinates,
            imageURL: restaurant.images.first?.image,
            price: restaurant.price,
            rating: Int(assessment?.rating ?? 0),
            assessmentsCountText: FormatterHelper.assessments(assessment?.number ?? 0),
            distance: distanceText,
            schedule: Array(schedules),
            deliveryTime: restaurant.deliveryTime ?? "",
            hasDelivery: (restaurant.deliveryLink?.count ?? 0) > 0,
            isClosed: restaurant.isClosed ?? false
        )
    }
}
