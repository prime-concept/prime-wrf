import UIKit

final class ProfileSettingsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileSettingsPresenter(
            clientService: ClientService.shared,
            authService: AuthService()
        )
        let viewController = ProfileSettingsViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
