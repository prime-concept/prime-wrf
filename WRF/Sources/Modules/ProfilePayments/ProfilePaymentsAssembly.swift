import UIKit

final class ProfilePaymentsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfilePaymentsPresenter(
            paymentsService: PaymentsService()
        )
        let viewController = ProfilePaymentsViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
