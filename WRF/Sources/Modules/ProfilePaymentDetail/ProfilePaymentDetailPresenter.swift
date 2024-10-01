import UIKit

protocol ProfilePaymentDetailPresenterProtocol {
    var isEditMode: Bool { get }

    func loadPayment()

    func addPayment(number: String, date: String)
    func savePayment(number: String, date: String)
    func removePayment()

    func findCardType(card text: String?)
}

final class ProfilePaymentDetailPresenter: ProfilePaymentDetailPresenterProtocol {
    weak var viewController: ProfilePaymentDetailViewControllerProtocol?

    var isEditMode: Bool

    private let paymentsService: PaymentsServiceProtocol
    private var payment: Payment?

    private var cardType: CardType = .none

    init(
        isEditMode: Bool,
        paymentsService: PaymentsServiceProtocol,
        payment: Payment?
    ) {
        self.isEditMode = isEditMode
        self.paymentsService = paymentsService
        self.payment = payment
    }

    // MARK: - Public API

    func loadPayment() {
        guard let payment = self.payment else {
            return
        }
        self.viewController?.set(payment: self.makeViewModel(from: payment))
    }

    func addPayment(number: String, date: String) {
        let payment = Payment(
            id: UUID.init().uuidString,
            number: number,
            date: date,
            type: self.cardType
        )
        self.paymentsService.add(payment: payment)
        self.viewController?.paymentCardAdded(payment: payment)
    }

    func savePayment(number: String, date: String) {
        guard let payment = self.payment else {
            return
        }
        let newPayment = Payment(
            id: payment.id,
            number: number,
            date: date,
            type: payment.type
        )
        self.paymentsService.save(payment: newPayment)
        self.viewController?.paymentCardSaved(payment: newPayment)
    }

    func removePayment() {
        guard let payment = self.payment else {
            return
        }
        self.paymentsService.remove(payment: payment)
        self.viewController?.paymentCardRemoved(payment: payment)
    }

    func findCardType(card text: String?) {
        let type = self.paymentsService.findCardType(card: text)
        self.cardType = type

        self.viewController?.set(cardImage: type.image)
    }

    // MARK: - Private API

    private func makeViewModel(from model: Payment) -> ProfilePaymentDetailViewModel {
        return ProfilePaymentDetailViewModel(
            cardNumber: model.number,
            cardDate: model.date,
            cardImage: model.type.image
        )
    }
}
