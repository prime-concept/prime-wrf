import UIKit

final class ProfileBookingAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileBookingPresenter(
            endpoint: HostessBookingEndpoint(),
            restaurantsEndpoint: RestaurantsEndpoint(),
            authService: AuthService()
        )
        let viewController = ProfileBookingViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
