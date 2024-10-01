import UIKit

final class SearchRestaurantAssembly: SearchChildAssembly {
    private lazy var presenter = SearchRestaurantPresenter(
        restaurantsEndpoint: RestaurantsEndpoint(),
        restaurantEndpoint: RestaurantEndpoint(), 
        tagsEndpoint: TagsEndpoint(),
        hostessScheduleEndpoint: HostessScheduleEndpoint(),
        favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
        feedbackEndpoint: PrimePassFeedbackEndpoint(),
        locationService: LocationService.shared
    )

    var moduleInput: SearchChildModuleInput {
        return self.presenter
    }

    func makeModule() -> UIViewController {
        let viewController = SearchRestaurantViewController(presenter: self.presenter)
        self.presenter.viewController = viewController
        return viewController
    }
}
