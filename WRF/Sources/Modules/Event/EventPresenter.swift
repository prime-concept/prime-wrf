import CoreLocation
import PromiseKit
import UIKit

protocol EventPresenterProtocol {
    func loadEvent()
    func updateFavoriteStatus()
    func select(participant: EventViewModel.Participant)
    func share()
}

final class EventPresenter: EventPresenterProtocol {
    private static let backgroundQueue = DispatchQueue.global(qos: .userInitiated)

    weak var viewController: EventViewControllerProtocol?

    private var event: Event
    private let eventEndpoint: EventEndpointProtocol
    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let sharingService: SharingServiceProtocol
    private let locationService: LocationServiceProtocol
    private let eventMetaPersistenceService: EventMetaPersistenceServiceProtocol

    private let dateFormatter: DateFormatter

    private var response: NavigatorItemResponse<Event>?
    private var assessments: [PrimePassAssessment] = []
    private var isFavorite = false

    init(
        event: Event,
        eventEndpoint: EventEndpointProtocol,
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        favoritesService: FavoritesServiceProtocol,
        sharingService: SharingServiceProtocol,
        locationService: LocationServiceProtocol,
        eventMetaPersistenceService: EventMetaPersistenceServiceProtocol
    ) {
        self.event = event
        self.eventEndpoint = eventEndpoint
        self.feedbackEndpoint = feedbackEndpoint
        self.favoritesService = favoritesService
        self.sharingService = sharingService
        self.locationService = locationService
        self.eventMetaPersistenceService = eventMetaPersistenceService

        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        self.dateFormatter = formatter

        self.isFavorite = event.isFavorite

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

    func loadEvent() {
        self.loadCachedEvent(event: self.event)

        let group = DispatchGroup()
        let queue = type(of: self).backgroundQueue

        let lastLocation = self.locationService.lastLocation

        var loadedEvent: NavigatorItemResponse<Event>?
        var loadedAssessments: [PrimePassAssessment] = []

        group.enter()
        queue.promise {
            self.eventEndpoint.retrieve(id: self.event.id).result
        }.then(on: queue) { response -> Promise<([Restaurant], [PrimePassAssessment])> in
            loadedEvent = response

            let restaurants = response.dependencies.restaurants
            let promises: [Promise<PrimePassArrayResponse<PrimePassAssessment>>] = restaurants.compactMap {
                if $0.primePassID.isEmpty {
                    return nil
                }

                return self.feedbackEndpoint.retrieveAssessment(place: $0.primePassID).result
            }
            return when(fulfilled: promises).map { (restaurants, $0.compactMap { $0.data?.first }) }
        }.then { restaurants, assessments -> Promise<([Restaurant], [PrimePassAssessment])> in
            let event = EventContainer(
                id: self.event.id,
                description: loadedEvent?.item.description,
                participants: restaurants,
                assessments: assessments
            )
            return self.eventMetaPersistenceService.save(event: event).map {
                (restaurants, assessments)
            }
        }.done { restaurants, assessments in
            loadedAssessments = assessments

            self.response = loadedEvent
            self.assessments = assessments

            guard let event = loadedEvent else {
                return
            }

            self.event = event.item

            let eventModel = self.makeViewModel(
                location: lastLocation,
                event: self.event,
                restaurants: restaurants,
                assessments: loadedAssessments,
                isFavorite: event.item.isFavorite
            )
            self.viewController?.set(event: eventModel)
        }.ensure {
            group.leave()
        }.catch { error in
            print("event presenter: error while loading event = \(error)")
        }

        guard lastLocation == nil else {
            return
        }

        self.locationService.fetchLocation { result in
            guard case .success(let location) = result else {
                return
            }
            group.notify(queue: .main) {
                guard let response = self.response else {
                    return
                }
                let event = self.makeViewModel(
                    location: CLLocation(latitude: location.latitude, longitude: location.longitude),
                    event: response.item,
                    restaurants: response.dependencies.restaurants,
                    assessments: loadedAssessments,
                    isFavorite: response.item.isFavorite
                )
                self.viewController?.set(event: event)
            }
        }
    }

    func updateFavoriteStatus() {
        type(of: self).backgroundQueue.promise {
            self.favoritesService.updateFavoritesStatus(
                resourceID: self.event.id,
                type: .events,
                isFavorite: self.isFavorite
            )
        }.catch { error in
            print("event presenter: error executing favorite status change = \(error)")
        }
    }

    func select(participant: EventViewModel.Participant) {
        guard let response = self.response else {
            return
        }
        guard let restaurant = response.dependencies.restaurants.first(
            where: { $0.id == participant.id }
        ) else {
            return
        }

        self.viewController?.present(restaurant: restaurant)
    }

    func share() {
        let object = DeeplinkContext.event(id: self.event.id, self.event)
        self.sharingService.share(object: object)
    }

    // MARK: - Private API

    private func loadCachedEvent(event: Event) {
        type(of: self).backgroundQueue.promise {
            self.eventMetaPersistenceService.retrieve(by: event.id)
        }.done { meta in
            guard let eventMeta = meta else {
                let viewModel = self.makeViewModel(location: nil, event: event, isFavorite: event.isFavorite)
                self.viewController?.set(event: viewModel)
                return
            }
            let newEvent = event.copyWithUpdatingParameters(description: eventMeta.description)
            self.event = newEvent

            let viewModel = self.makeViewModel(
                location: self.locationService.lastLocation,
                event: newEvent,
                restaurants: eventMeta.participants,
                assessments: eventMeta.assessments,
                isFavorite: newEvent.isFavorite
            )
            self.viewController?.set(event: viewModel)
        }.cauterize()
    }

    @objc
    private func resourceFavorited(notification: Notification) {
        guard let resourceId = FavoritesService.extractEventFavorite(from: notification),
              resourceId == self.event.id,
              let response = self.response else {
            return
        }

        self.isFavorite = true

        let model = self.makeViewModel(
            location: self.locationService.lastLocation,
            event: self.event,
            restaurants: response.dependencies.restaurants,
            assessments: self.assessments,
            isFavorite: true
        )
        self.viewController?.set(event: model)
    }

    @objc
    private func resourceUnfavorited(notification: Notification) {
        guard let resourceId = FavoritesService.extractEventFavorite(from: notification),
              resourceId == self.event.id,
              let response = self.response else {
            return
        }

        self.isFavorite = false

        let model = self.makeViewModel(
            location: self.locationService.lastLocation,
            event: self.event,
            restaurants: response.dependencies.restaurants,
            assessments: self.assessments,
            isFavorite: false
        )
        self.viewController?.set(event: model)
    }

    private func makeViewModel(
        location: CLLocation?,
        event: Event,
        restaurants: [Restaurant] = [],
        assessments: [PrimePassAssessment] = [],
        isFavorite: Bool
    ) -> EventViewModel {
        let participants: [EventViewModel.Participant] = restaurants
            .filter { event.restaurantsIDs?.contains($0.id) ?? false }
            .map { restaurant in
                let assessment = assessments.first(where: { $0.place == restaurant.primePassID })
                return self.makeViewModel(
                    location: location,
                    restaurant: restaurant,
                    assessment: assessment
                )
            }

        let dateString = event.schedule.map { self.dateFormatter.string(from: $0) }.joined(separator: " - ")

        return EventViewModel(
            title: event.title,
            description: event.description,
            bookingText: event.bookingText,
            isFavorite: isFavorite,
            date: dateString,
            imageURL: event.images?.first?.image,
            participants: participants,
            bookingLink: event.bookingLink,
            buttonTitle: event.buttonName
        )
    }

    private func makeViewModel(
        location: CLLocation?,
        restaurant: Restaurant,
        assessment: PrimePassAssessment?
    ) -> EventViewModel.Participant {
        var distanceText: String?
        if let to = location, let coordinates = restaurant.coordinates {
            distanceText = FormatterHelper.distanceRepresentation(
                distanceInMeters: to.distance(from: coordinates.location)
            )
        }
        return EventViewModel.Participant(
            id: restaurant.id,
            title: restaurant.title,
            address: restaurant.address,
            isFavorite: restaurant.isFavorite,
            imageURL: restaurant.images.first?.image,
            logoURL: restaurant.logos?.first?.image,
            distanceText: distanceText,
            price: restaurant.price,
            rating: Int(assessment?.rating ?? 0),
            assessmentsCountText: FormatterHelper.assessments(assessment?.number ?? 0)
        )
    }
}
