import CoreLocation
import Foundation
import PromiseKit

protocol RestaurantPresenterProtocol: AnyObject {
    func loadRestaurant()
    func updateFavoriteStatus(isFavorite: Bool)

    func requestEventPresentation(position: Int)
    func share()
    func didTapOnPhotoGallery()
    func didTapOnOpenWebpage()
    func didCallRestaurantForBooking()
    func didCallRestaurantForInfo()
    func didScrollRestaurantReviews()
    func didTapOnDeliveryButton()
}

final class RestaurantPresenter: RestaurantPresenterProtocol {
    private typealias ReviewData = PrimePassReview

    weak var viewController: RestaurantViewControllerProtocol?

    private var restaurant: Restaurant
    private var assessment: PrimePassAssessment?
    private var events: [Event] = []
    private var tags: [Tag] = []

    private let restaurantEndpoint: RestaurantEndpointProtocol
    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let locationService: LocationServiceProtocol
    private let sharingService: SharingServiceProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let restaurantPersistenceService: RestaurantsPersistenceService
    private let restaurantDetailPersistenceService: RestaurantDetailPersistenceService
    private let authService: AuthServiceProtocol

    init(
        restaurant: Restaurant,
        assessment: PrimePassAssessment?,
        restaurantEndpoint: RestaurantEndpointProtocol,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        sharingService: SharingServiceProtocol,
        locationService: LocationServiceProtocol,
        favoritesService: FavoritesServiceProtocol,
        restaurantPersistenceService: RestaurantsPersistenceService,
        restaurantDetailPersistenceService: RestaurantDetailPersistenceService,
        authService: AuthServiceProtocol
    ) {
        self.restaurant = restaurant
        self.assessment = assessment
        self.restaurantEndpoint = restaurantEndpoint
        self.feedbackEndpoint = feedbackEndpoint
        self.sharingService = sharingService
        self.locationService = locationService
        self.favoritesService = favoritesService
        self.restaurantPersistenceService = restaurantPersistenceService
        self.restaurantDetailPersistenceService = restaurantDetailPersistenceService
        self.authService = authService

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

    func loadRestaurant() {
        self.loadCachedRestaurant(
            restaurant: self.restaurant,
            assessment: self.assessment,
            location: self.locationService.lastLocation?.coordinate
        )

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            // swiftlint:disable:next operator_usage_whitespace
            () -> Promise<(
                NavigatorItemResponse<Restaurant>,
                PrimePassArrayResponse<PrimePassAssessment>,
                [ReviewData]
            )> in

			let mayShowAssessment = self.restaurant.primePassID.count > 0 && self.authService.isAuthorized

            let assesment: Promise<PrimePassArrayResponse<PrimePassAssessment>> = mayShowAssessment
				? self.feedbackEndpoint.retrieveAssessment(place: self.restaurant.primePassID).result
				: .value(PrimePassArrayResponse<PrimePassAssessment>(status: .ok, data: [], error: nil))

            return when(
                fulfilled: self.restaurantEndpoint.retrieve(id: self.restaurant.id).result,
                assesment,
                self.retrieveReviews(place: self.restaurant.primePassID)
            )
        }.then(on: queue) {
            // swiftlint:disable:next operator_usage_whitespace
            result -> Promise<(
                NavigatorItemResponse<Restaurant>, PrimePassArrayResponse<PrimePassAssessment>, [ReviewData]
            )> in
            let (restaurantResponse, assessments, reviews) = result
            return self.saveRestaurant(
                response: restaurantResponse,
                assessment: assessments.data?.first,
                reviews: reviews
            ).map { result }
        }.done { result in
            let (restaurantResponse, assessmentsResponse, reviews) = result

            let events = restaurantResponse.dependencies.events
            self.events = events

            let tags = restaurantResponse.dependencies.cuisines
                + restaurantResponse.dependencies.restServices
                + restaurantResponse.dependencies.special
            self.tags = tags

            self.viewController?.set(
                restaurant: self.makeViewModel(
                    restaurant: restaurantResponse.item,
                    events: events,
                    tags: tags,
                    assessment: assessmentsResponse.data?.first,
                    reviews: reviews
                )
            )
            self.viewController?.set(isFavorite: restaurantResponse.item.isFavorite)

            NotificationCenter.default.post(
                name: .restaurantLocationUpdate,
                object: nil,
                userInfo: ["restaurant": restaurantResponse.item]
            )

            self.locationService.fetchLocation(
                completion: { result in
                    guard case .success(let location) = result else {
                        return
                    }

                    let events = restaurantResponse.dependencies.events
                    self.events = events

                    self.viewController?.set(
                        restaurant: self.makeViewModel(
                            restaurant: restaurantResponse.item,
                            location: location,
                            events: self.events,
                            tags: self.tags,
                            assessment: assessmentsResponse.data?.first,
                            reviews: reviews
                        )
                    )

                    self.viewController?.set(isFavorite: restaurantResponse.item.isFavorite)
                }
            )
		}.catch { error in
			print("ERROR LOADING RESTAURANT DETAILS: \(error)")
		}
    }

    func updateFavoriteStatus(isFavorite: Bool) {
        guard self.authService.isAuthorized else {
            self.viewController?.handleUnauthorizedUser()
            return
        }
        
        AnalyticsReportingService.shared.didUpdateFavoriteState(restaurantId: self.restaurant.id,
                                                                isFavorite: !isFavorite)
        
        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesService.updateFavoritesStatus(
                resourceID: self.restaurant.id,
                type: .restaurants,
                isFavorite: isFavorite
            )
        }.catch { error in
            print("event presenter: error executing favorite status change = \(error)")
        }
    }

    func requestEventPresentation(position: Int) {
        guard let event = self.events[safe: position] else {
            return
        }
        AnalyticsReportingService.shared.didTapOnEventsItem(restaurantId: self.restaurant.id,
                                                            eventId: event.id)
        self.viewController?.present(event: event)
    }

    func share() {
        AnalyticsReportingService.shared.didTapOnShareButton(restaurantId: self.restaurant.id)
        
        let object = DeeplinkContext.restaurant(id: self.restaurant.id, self.restaurant)
        self.sharingService.share(object: object)
    }
    
    func didTapOnPhotoGallery() {
        AnalyticsReportingService.shared.didTapOnPhotoGallery(restaurantId: self.restaurant.id)
    }
    
    func didTapOnOpenWebpage() {
        AnalyticsReportingService.shared.didTapOnOpenWebpage(restaurantId: self.restaurant.id)
    }
    
    func didCallRestaurantForBooking() {
        AnalyticsReportingService.shared.didCallRestaurantForBooking(restaurantId: self.restaurant.id,
                                                                     name: self.restaurant.title,
                                                                     phoneNumber: self.restaurant.phone ?? "")
    }
    
    func didCallRestaurantForInfo() {
        AnalyticsReportingService.shared.didCallRestaurantForInfo(restaurantId: self.restaurant.id,
                                                                  name: self.restaurant.title,
                                                                  phoneNumber: self.restaurant.phone ?? "")
    }
    
    func didScrollRestaurantReviews() {
        AnalyticsReportingService.shared.didScrollRestaurantReviews(restaurantId: self.restaurant.id)
    }
    
    func didTapOnDeliveryButton() {
        AnalyticsReportingService.shared.didTapOnDeliveryButton(restaurantId: self.restaurant.id)
    }

    // MARK: - Private API

    private func retrieveReviews(place: PrimePassRestaurantIDType) -> Promise<[ReviewData]> {
		if place.isEmpty || !self.authService.isAuthorized {
            return .value([])
        }

        let queue = DispatchQueue.global(qos: .userInitiated)
        return queue.promise {
            self.feedbackEndpoint.retrieveReviews(place: self.restaurant.primePassID).result
        }.then(on: queue) { Promise.value($0.data ?? []) }
    }

    @objc
    private func resourceFavorited(notification: Notification) {
        guard let resourceID = FavoritesService.extractRestaurantFavorite(from: notification),
              resourceID == self.restaurant.id else {
            return
        }

        self.viewController?.set(isFavorite: true)
    }

    @objc
    private func resourceUnfavorited(notification: Notification) {
        guard let resourceID = FavoritesService.extractRestaurantFavorite(from: notification),
              resourceID == self.restaurant.id else {
            return
        }

        self.viewController?.set(isFavorite: false)
    }

    private func loadCachedRestaurant(
        restaurant: Restaurant,
        assessment: PrimePassAssessment?,
        location: CLLocationCoordinate2D?
    ) {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            when(
                fulfilled:
                self.restaurantPersistenceService.retrieve(by: restaurant.id),
                self.restaurantDetailPersistenceService.retrieve(by: restaurant.id)
            )
        }.done { cachedRestaurant, cachedRestaurantMeta in
            guard let cachedRestaurant = cachedRestaurant,
                  let restaurantMeta = cachedRestaurantMeta else {
                self.viewController?.set(
                    restaurant: self.makeViewModel(
                        restaurant: restaurant,
                        location: location,
                        assessment: assessment
                    )
                )
                return
            }

            self.events = restaurantMeta.events

            let newRestaurant = cachedRestaurant.copyWithUpdatingParameters(
                description: restaurantMeta.description,
                phone: restaurantMeta.phone,
                menu: restaurantMeta.menu,
                site: restaurantMeta.site,
                previewImages360: restaurantMeta.previewImages360,
                eventIDs: restaurantMeta.events.map { $0.id }
            )
            self.viewController?.set(
                restaurant: self.makeViewModel(
                    restaurant: newRestaurant,
                    location: location,
                    events: restaurantMeta.events,
                    tags: restaurantMeta.tags,
                    assessment: assessment ?? restaurantMeta.assessment,
                    reviews: restaurantMeta.reviews
                )
            )
            self.viewController?.set(
                isFavorite: newRestaurant.isFavorite
            )
        }.cauterize()
    }

    private func saveRestaurant(
        response: NavigatorItemResponse<Restaurant>,
        assessment: PrimePassAssessment?,
        reviews: [ReviewData]
    ) -> Promise<Void> {
        return Promise<Void> { seal in
            let restaurant = response.item
            let container = RestaurantDetailContainer(
                id: restaurant.id,
                description: restaurant.description,
                phone: restaurant.phone,
                menu: restaurant.menu,
                site: restaurant.site,
                assessment: assessment,
                events: response.dependencies.events,
                tags: response.dependencies.tags,
                reviews: reviews,
                previewImages360: restaurant.previewImages360 ?? []
            )
            when(
                fulfilled: [
                    self.restaurantPersistenceService.save(restaurant: restaurant),
                    self.restaurantDetailPersistenceService.save(restaurant: container)
                ]
            ).done { _ in
                seal.fulfill_()
            }.cauterize()
        }
    }

    private func makeViewModel(
        restaurant: Restaurant,
        location: CLLocationCoordinate2D? = nil,
        events: [Event] = [],
        tags: [Tag] = [],
        assessment: PrimePassAssessment?,
        reviews: [ReviewData] = [],
        taxi: TaxiResponse? = nil
    ) -> RestaurantViewModel {
        let events = events
            .filter { restaurant.eventsIDs?.contains($0.id) ?? false }
            .map { self.makeViewModel(event: $0) }

        let panorama: RestaurantViewModel.Panorama? = {
            let images = (restaurant.images360 ?? []).map { $0.image }
            let previews = (restaurant.previewImages360 ?? []).map { $0.image }

            guard !images.isEmpty, !previews.isEmpty else {
                return nil
            }

            return RestaurantViewModel.Panorama(images: zip(images, previews).map { ($0, $1) })
        }()

        var rating: Int?
        var assessmentsCountText: String?
        if let assessment = assessment {
            rating = Int(assessment.rating)
            assessmentsCountText = FormatterHelper.assessments(assessment.number)
        }

        let reviews = reviews.map { self.makeViewModel(review: $0) }

        let distanceText: String? = {
            if location != nil,
               let coordinate = restaurant.coordinates?.coordinate,
               let distance = self.locationService.distanceFromLocation(to: coordinate) {
                return FormatterHelper.distanceRepresentation(distanceInMeters: distance)
            }
            return nil
        }()

        let workingTime: RestaurantViewModel.WorkingTime? = {
            if let workingTime = restaurant.workingTime,
               let start = workingTime.startTime,
               let end = workingTime.endTime {
                return RestaurantViewModel.WorkingTime(
                    days: "пн-вс",
                    hours: "\(start) – \(end)"
                )
            }
            return nil
        }()

        let phone: String? = {
            if let phone = restaurant.phone, !phone.isEmpty {
                return phone
            }
            return nil
        }()

        let tagsIDs = (restaurant.cuisinesIDs ?? [])
            + (restaurant.restServicesIDs ?? [])
            + (restaurant.specialIDs ?? [])
        let tags = tags.filter { tagsIDs.contains($0.id) }.map { $0.title.lowercased() }

        let deliveryLink = restaurant.deliveryLink ?? ""
        let deliveryFrameID = deliveryLink.isEmpty ? nil : deliveryLink

        var coordninate: (Double, Double)? = nil
        if let coordinates = restaurant.coordinates {
            coordninate = (coordinates.latitude, coordinates.longitude)
        }

        return RestaurantViewModel(
            title: restaurant.title,
            address: restaurant.address,
            description: restaurant.description,
            distanceText: distanceText,
            imageURL: restaurant.images.first?.image,
            events: events,
            panorama: panorama,
            rating: rating,
            ratingFloat: assessment?.rating,
            assessmentsCountText: assessmentsCountText,
            assessmentsCount: assessment?.number,
            reviews: reviews,
            price: restaurant.price,
            workingTime: workingTime,
            phone: phone,
            coordinate: coordninate,
            isFavorite: nil,
            site: restaurant.site ?? "https://wrf.su/ru/",
            images: restaurant.images,
            tags: tags,
            deliveryFrameID: deliveryFrameID,
            canReserve: restaurant.canReserve ?? false,
            isClosed: restaurant.isClosed ?? false,
            menu: restaurant.menu
        )
    }

    private func makeViewModel(review: ReviewData) -> RestaurantViewModel.Review {
        var userName = "Гость"
        if let name = review.clientName, let surname = review.clientSurname {
            userName = "\(name) \(surname)"
        }

        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "d MMM yyyy"

        return RestaurantViewModel.Review(
            userImage: review.avatar?.asImage ?? #imageLiteral(resourceName: "user-image"),
            userName: userName,
            dateText: formatter.string(from: review.timeKey),
            rating: review.assessment,
            text: review.review ?? ""
        )
    }

    private func makeViewModel(event: Event) -> RestaurantViewModel.Event {
        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "d MMM yyyy"

        let dateString = event.schedule.map { formatter.string(from: $0) }.joined(separator: " - ")

        return RestaurantViewModel.Event(
            title: event.title,
            imageURL: event.images?.first?.image,
            date: dateString
        )
    }
}
