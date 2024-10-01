import UIKit

final class ProfilePaymentDetailAssembly: Assembly {
    private var payment: Payment?

    init(payment: Payment?) {
        self.payment = payment
    }

    func makeModule() -> UIViewController {
        let presenter = ProfilePaymentDetailPresenter(
            isEditMode: self.payment != nil,
            paymentsService: PaymentsService(),
            payment: self.payment
        )
        let viewController = ProfilePaymentDetailViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
