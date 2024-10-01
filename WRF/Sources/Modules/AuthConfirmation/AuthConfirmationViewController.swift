import DeviceKit
import IQKeyboardManagerSwift
import UIKit

protocol AuthConfirmationViewControllerProtocol: BlockingLoaderPresentable {
    /// Update "send again" timer
    func updateSMSCodeStatus()

    func dismissAuthorization()
    func showError(_ error: AuthConfirmationError)
}

final class AuthConfirmationViewController: UIViewController {
    let presenter: AuthConfirmationPresenterProtocol

    lazy var authConfirmationView = self.view as? AuthConfirmationView

    init(presenter: AuthConfirmationPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = AuthConfirmationView(frame: UIScreen.main.bounds, isSmallScreen: Device.current.diagonal <= 4)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.authConfirmationView?.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
}

extension AuthConfirmationViewController: AuthConfirmationViewControllerProtocol {
    func updateSMSCodeStatus() {
        self.hideLoading()
        self.authConfirmationView?.updateForNextSMS()
    }

    func dismissAuthorization() {
        DispatchQueue.main.async {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }

    func showError(_ error: AuthConfirmationError) {
        let message: String

        switch error {
        case .invalidCode:
            message = "Неверный код"
        case .unrecognized:
            message = "Неизвестная ошибка"
        }

        self.authConfirmationView?.showError(message: message)
    }
}

extension AuthConfirmationViewController: AuthConfirmationViewDelegate {
    func authConfirmationView(_ view: AuthConfirmationView, didRequestAction viewModel: AuthConfirmationViewModel) {
        self.presenter.submitAction(viewModel: viewModel)
        self.showLoading()
    }

    func authConfirmationViewDidRequestCode(_ view: AuthConfirmationView) {
        self.presenter.requestCode()
        self.showLoading()
    }

    func authConfirmationViewWantsClose(_ view: AuthConfirmationView) {
        self.dismiss(animated: true, completion: nil)
    }
}
