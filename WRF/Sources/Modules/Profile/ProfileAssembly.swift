import UIKit

final class ProfileAssembly: Assembly {
    private static var instance: UIViewController?

    init() {
        Notification.onReceive(.logout) { _ in
            Self.instance = nil
        }
    }

    func makeModule() -> UIViewController {
        if let instance = Self.instance {
            return instance
        }

        let authService = AuthService()
        let profilePresenter = ProfilePresenter(
            hostessBookingEndpoint: HostessBookingEndpoint(),
            endpoint: PrimePassClientEndpoint(),
            clientService: ClientService.shared,
            authService: authService
        )
        let viewController = ProfileViewController(presenter: profilePresenter)
        profilePresenter.viewController = viewController
        Self.instance = viewController

        return viewController
    }
}
