import UIKit

protocol ProfilePaymentsViewControllerProtocol: AnyObject {
    func set(payments: [ProfilePaymentViewModel])
    func set(payment: ProfilePaymentViewModel)

    func add(payment: ProfilePaymentViewModel)
    func remove(at index: Int)

    func show(payment: Payment)
}

protocol ProfilePaymentsViewControllerDelegate: AnyObject {
    func paymentCardAdded(payment: Payment)
    func paymentCardSaved(payment: Payment)
    func paymentCardRemoved(payment: Payment)
}

final class ProfilePaymentsViewController: UIViewController {
    static let floatingControllerGroupID = "payments"

    let presenter: ProfilePaymentsPresenterProtocol
    private lazy var profilePaymentsView = self.view as? ProfilePaymentsView

    private var payments: [ProfilePaymentViewModel] = []

    private lazy var paymentDetailPresentationManager = FloatingControllerPresentationManager(
        context: .payment(keyboardHeight: 0),
        groupID: ProfilePaymentsViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    init(presenter: ProfilePaymentsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfilePaymentsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Способы оплаты"
        self.navigationItem.setBackButtonText()

        self.presenter.loadPayments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private API

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc
    private func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let rect = keyboardFrame.cgRectValue
                let height = rect.height
                self.paymentDetailPresentationManager.context = .payment(
                    keyboardHeight: height
                )
            }
        }
    }

    @objc
    private func keyboardWillHide(notification: Notification) {
        self.paymentDetailPresentationManager.context = .payment(keyboardHeight: 0)
    }

    private func checkAndAddPaymentAddButton() {
        guard !self.payments.isEmpty else {
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        let button = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(self.showPaymentAddDialog)
        )
        self.navigationItem.rightBarButtonItem = button
    }

    @objc
    private func showPaymentAddDialog() {
        let controller = ProfilePaymentDetailAssembly(payment: nil).makeModule()
        if let viewController = controller as? ProfilePaymentDetailViewController {
            viewController.delegate = self
        }
        self.paymentDetailPresentationManager.contentViewController = controller
        self.paymentDetailPresentationManager.present()
    }
}

extension ProfilePaymentsViewController: ProfilePaymentsViewControllerProtocol {
    func set(payments: [ProfilePaymentViewModel]) {
        self.payments = payments
        self.profilePaymentsView?.showEmptyView = payments.isEmpty
        self.profilePaymentsView?.updateCollectionView(delegate: self, dataSource: self)

        self.checkAndAddPaymentAddButton()
    }

    func set(payment: ProfilePaymentViewModel) {
        let indexPath = IndexPath(row: payment.id, section: 0)
        self.payments[indexPath.row] = payment
        self.profilePaymentsView?.paymentsCollectionView.reloadItems(at: [indexPath])
    }

    func add(payment: ProfilePaymentViewModel) {
        let indexPath = IndexPath(row: payment.id, section: 0)
        self.payments.append(payment)
        self.profilePaymentsView?.showEmptyView = self.payments.isEmpty
        self.profilePaymentsView?.paymentsCollectionView.insertItems(at: [indexPath])

        self.checkAndAddPaymentAddButton()
    }

    func remove(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.payments.remove(at: indexPath.row)
        self.profilePaymentsView?.showEmptyView = self.payments.isEmpty
        self.profilePaymentsView?.paymentsCollectionView.deleteItems(at: [indexPath])

        self.checkAndAddPaymentAddButton()
    }

    func show(payment: Payment) {
        let controller = ProfilePaymentDetailAssembly(payment: payment).makeModule()
        if let viewController = controller as? ProfilePaymentDetailViewController {
            viewController.delegate = self
        }
        self.paymentDetailPresentationManager.contentViewController = controller
        self.paymentDetailPresentationManager.present()
    }
}

extension ProfilePaymentsViewController: ProfilePaymentsViewDelegate {
    func viewDidRequestPaymentAdd() {
        self.showPaymentAddDialog()
    }
}

extension ProfilePaymentsViewController: ProfilePaymentsViewControllerDelegate {
    func paymentCardAdded(payment: Payment) {
        self.presenter.add(payment: payment)
    }

    func paymentCardSaved(payment: Payment) {
        self.presenter.save(payment: payment)
    }

    func paymentCardRemoved(payment: Payment) {
        self.presenter.remove(payment: payment)
    }
}

extension ProfilePaymentsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return self.profilePaymentsView?.appearance.itemSize ?? .zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.payments[indexPath.row]
        self.presenter.select(model: model)
    }
}

extension ProfilePaymentsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.payments.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: ProfilePaymentsCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.payments[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}
