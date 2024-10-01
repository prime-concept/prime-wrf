import UIKit

final class EventsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = EventsPresenter(
            eventsEndpoint: EventsEndpoint(),
            tagsEndpoint: TagsEndpoint(),
            favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
            eventsPersistenceService: EventsPersistenceService.shared,
            eventListContainerPersistenceService: EventListContainerPersistenceService.shared,
            youtubeVideosEndpoint: YoutubeVideosEndpoint(),
            youtubeService: YoutubeService()
        )
        let viewController = EventsViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
