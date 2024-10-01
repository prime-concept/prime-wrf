import SafariServices
import UIKit

final class EventAssembly: Assembly {
    private let event: Event

    private(set) var trackedScrollView: UIScrollView?

    init(event: Event) {
        self.event = event
    }

    func makeModule() -> UIViewController {
        let presenter = EventPresenter(
            event: self.event,
            eventEndpoint: EventEndpoint(),
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
            favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
            sharingService: SharingService(),
            locationService: LocationService.shared,
            eventMetaPersistenceService: EventMetaPersistenceService.shared
        )
        let viewController = EventViewController(presenter: presenter)
        presenter.viewController = viewController

        self.trackedScrollView = viewController.eventView?.scrollView

        return viewController
    }
}
