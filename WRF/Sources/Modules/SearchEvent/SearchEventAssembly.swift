import UIKit

final class SearchEventAssembly: SearchChildAssembly {
    private lazy var presenter = SearchEventPresenter(
        eventsEndpoint: EventsEndpoint(),
        eventEndpoint: EventEndpoint(),
        tagsEndpoint: TagsEndpoint(),
        favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint())
    )

    var moduleInput: SearchChildModuleInput {
        return self.presenter
    }

    func makeModule() -> UIViewController {
        let viewController = SearchEventViewController(presenter: self.presenter)
        self.presenter.viewController = viewController
        return viewController
    }
}
