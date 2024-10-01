import UIKit

final class RestaurantLocationAssembly: Assembly {
    private let restaurant: Restaurant

    init(restaurant: Restaurant) {
        self.restaurant = restaurant
    }

    func makeModule() -> UIViewController {
        let presenter = RestaurantLocationPresenter(
            restaurant: self.restaurant,
            endpoint: TaxiEndpoint(),
            locationService: LocationService.shared
        )
        let viewController = RestaurantLocationViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
