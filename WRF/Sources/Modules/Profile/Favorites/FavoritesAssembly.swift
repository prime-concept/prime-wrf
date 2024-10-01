import UIKit

final class FavoritesAssembly: Assembly {
    private weak var moduleOutput: FavoritesModuleOutput?

    init(moduleOutput: FavoritesModuleOutput? = nil) {
        self.moduleOutput = moduleOutput
    }

    func makeModule() -> UIViewController {
        let presenter = FavoritesPresenter(
            favoritesEndpoint: FavoritesEndpoint(),
            favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
            eventEndpoint: EventEndpoint(),
            restaurantEndpoint: RestaurantEndpoint(),
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
            locationService: LocationService.shared
        )
        let viewController = FavoritesViewController(presenter: presenter, moduleOutput: self.moduleOutput)
        presenter.viewController = viewController

        return viewController
    }
}
