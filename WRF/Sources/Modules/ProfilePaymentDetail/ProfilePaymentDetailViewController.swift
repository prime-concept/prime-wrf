import IQKeyboardManagerSwift
import UIKit

protocol ProfilePaymentDetailViewControllerProtocol: AnyObject {
    func paymentCardAdded(payment: Payment)
    func paymentCardSaved(payment: Payment)
    func paymentCardRemoved(payment: Payment)

    func set(payment: ProfilePaymentDetailViewModel)
    func set(cardImage image: UIImage?)
}

final class ProfilePaymentDetailViewController: UIViewController {
    let presenter: ProfilePaymentDetailPresenterProtocol
    private lazy var paymentDetailView = self.view as? ProfilePaymentDetailView

    weak var delegate: ProfilePaymentsViewControllerDelegate?

    init(presenter: ProfilePaymentDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfilePaymentDetailView(
            frame: UIScreen.main.bounds,
            isEditMode: self.presenter.isEditMode
        )
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadPayment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
}

extension ProfilePaymentDetailViewController: ProfilePaymentDetailViewControllerProtocol {
    func paymentCardAdded(payment: Payment) {
        self.delegate?.paymentCardAdded(payment: payment)
        self.fp_dismiss(animated: true)
    }

    func paymentCardSaved(payment: Payment) {
        self.delegate?.paymentCardSaved(payment: payment)
        self.fp_dismiss(animated: true)
    }

    func paymentCardRemoved(payment: Payment) {
        self.delegate?.paymentCardRemoved(payment: payment)
        self.fp_dismiss(animated: true)
    }

    func set(payment: ProfilePaymentDetailViewModel) {
        self.paymentDetailView?.cardNumber = payment.cardNumber
        self.paymentDetailView?.cardDate = payment.cardDate
        self.paymentDetailView?.cardImage = payment.cardImage
    }

    func set(cardImage image: UIImage?) {
        self.paymentDetailView?.cardImage = image
    }
}

extension ProfilePaymentDetailViewController: ProfilePaymentDetailViewDelegate {
    func addPayment(number: String, date: String) {
        self.presenter.addPayment(number: number, date: date)
    }

    func savePayment(number: String, date: String) {
        self.presenter.savePayment(number: number, date: date)
    }

    func removePayment() {
        self.presenter.removePayment()
    }

    func isEditingCardNumber(newText: String?) {
        self.presenter.findCardType(card: newText)
    }
}
