import PromiseKit
import UIKit

protocol ProfilePaymentsPresenterProtocol {
    func loadPayments()

    func select(model: ProfilePaymentViewModel)

    func add(payment: Payment)
    func save(payment: Payment)
    func remove(payment: Payment)
}

final class ProfilePaymentsPresenter: ProfilePaymentsPresenterProtocol {
    weak var viewController: ProfilePaymentsViewControllerProtocol?

    private let paymentsService: PaymentsServiceProtocol

    private var payments: [Payment] = []

    init(paymentsService: PaymentsServiceProtocol) {
        self.paymentsService = paymentsService
    }

    func loadPayments() {
        self.payments = self.paymentsService.getPayments()
        self.viewController?.set(
            payments: self.payments.enumerated().compactMap {
                self.makeViewModel(index: $0, from: $1)
            }
        )
    }

    func select(model: ProfilePaymentViewModel) {
        guard let payment = self.payments[safe: model.id] else {
            return
        }
        self.viewController?.show(payment: payment)
    }

    func add(payment: Payment) {
        self.payments.append(payment)

        let model = self.makeViewModel(index: self.payments.count - 1, from: payment)
        self.viewController?.add(payment: model)
    }

    func save(payment: Payment) {
        guard let index = self.payments.firstIndex(where: { $0.id == payment.id }) else {
            return
        }
        self.payments[index] = payment
        let model = self.makeViewModel(index: index, from: payment)
        self.viewController?.set(payment: model)
    }

    func remove(payment: Payment) {
        guard let index = self.payments.firstIndex(where: { $0.id == payment.id }) else {
            return
        }
        self.payments.remove(at: index)
        self.viewController?.remove(at: index)
    }

    // MARK: - Private API

    private func makeViewModel(index: Int, from model: Payment) -> ProfilePaymentViewModel {
        return ProfilePaymentViewModel(
            id: index,
            number: model.hiddenNumber,
            date: model.date,
            image: model.type == .visa ? #imageLiteral(resourceName: "payment-visa") : #imageLiteral(resourceName: "payment-master-card")
        )
    }
}
