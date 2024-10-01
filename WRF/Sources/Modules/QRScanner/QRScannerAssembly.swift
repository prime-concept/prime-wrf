import UIKit

final class QRScannerAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = QRScannerPresenter(
            endpoint: PrimePassCodeEndpoint(),
            authService: AuthService()
        )
        let viewController = QRScannerViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
