import UIKit

final class AuthAssembly: Assembly {
    private let withHeader: Bool
    private let withLogo: Bool
    private let page: AuthPage
	private let onAuthorize: (() -> Void)?

    init(
		withHeader: Bool = true, 
		withLogo: Bool = true,
		page: AuthPage = .signIn,
		onAuthorize: (() -> Void)? = nil
	) {
        self.withHeader = withHeader
        self.withLogo = withLogo
        self.page = page
		self.onAuthorize = onAuthorize
    }

    func makeModule() -> UIViewController {
        let presenter = AuthPresenter(
            primePassClientEndpoint: PrimePassClientEndpoint(),
            primePassAuthorizationEndpoint: PrimePassAuthorizationEndpoint(),
			onAuthorize: self.onAuthorize
        )
        let viewController = AuthViewController(
            presenter: presenter,
            withHeader: self.withHeader,
            withLogo: self.withLogo,
            page: self.page
        )
        presenter.viewController = viewController
        return viewController
    }
}
