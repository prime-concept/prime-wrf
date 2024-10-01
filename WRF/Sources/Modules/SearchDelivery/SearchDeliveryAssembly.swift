import UIKit

final class SearchDeliveryAssembly: SearchChildAssembly {
    private lazy var presenter = SearchDeliveryPresenter(
        restaurantsEndpoint: RestaurantsEndpoint(),
        restaurantEndpoint: RestaurantEndpoint(),
        hostessScheduleEndpoint: HostessScheduleEndpoint(),
        favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
        feedbackEndpoint: PrimePassFeedbackEndpoint(),
        locationService: LocationService.shared
    )

    var moduleInput: SearchChildModuleInput {
        return self.presenter
    }

    func makeModule() -> UIViewController {
        let viewController = SearchDeliveryViewController(presenter: self.presenter)
        self.presenter.viewController = viewController
        return viewController
    }
}
