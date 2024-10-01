import UIKit

final class ProfileEditAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileEditPresenter(
            clientEndpoint: PrimePassClientEndpoint(),
            clientService: ClientService.shared,
            authService: AuthService()
        )
        let viewController = ProfileEditViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
