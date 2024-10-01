import UIKit

final class AuthConfirmationAssembly: Assembly {
    private let phoneNumber: String
	private let onAuthorize: (() -> Void)?

    init(phoneNumber: String, onAuthorize: (() -> Void)?) {
        self.phoneNumber = phoneNumber
		self.onAuthorize = onAuthorize
    }

    func makeModule() -> UIViewController {
        let presenter = AuthConfirmationPresenter(
            phoneNumber: self.phoneNumber,
            primePassAuthorizationEndpoint: PrimePassAuthorizationEndpoint(),
            notificationTokenRegisterService: NotificationsTokenRegisterService.shared,
            authService: AuthService(),
			onAuthorize: self.onAuthorize
        )
        let viewController = AuthConfirmationViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
