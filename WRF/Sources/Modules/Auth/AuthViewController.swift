import DeviceKit
import IQKeyboardManagerSwift
import MBProgressHUD
import UIKit

protocol AuthViewControllerProtocol: BlockingLoaderPresentable {
	func presentConfirmation(phoneNumber: String, completion: (() -> Void)?)
    func showError(_ error: AuthError)
}

final class AuthViewController: UIViewController {
    lazy var authView = self.view as? AuthView

    private let presenter: AuthPresenterProtocol
    private let needsHeader: Bool
    private let withLogo: Bool
    private let page: AuthPage

    init(
        presenter: AuthPresenterProtocol,
        withHeader needsHeader: Bool = true,
        withLogo: Bool = true,
        page: AuthPage = .signIn
    ) {
        self.presenter = presenter
        self.needsHeader = needsHeader
        self.withLogo = withLogo
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = AuthView(
            frame: UIScreen.main.bounds,
            isSmallScreen: Device.current.diagonal <= 4,
            withHeader: self.needsHeader,
            withLogo: self.withLogo,
            page: self.page
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.authView?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
}

extension AuthViewController: AuthViewControllerProtocol {
    func showError(_ error: AuthError) {
        let message: String

        switch error {
        case .userNotFound:
            message = "Пользователь не найден"
        case .userAlreadyExists:
            message = "Введенный номер занят"
        case .unrecognized:
			DebugUtils.shared.alert(title: "Что-то пошло не так, попробуйте позже", action: "ОК")
			return
        }

        self.authView?.showError(message: message)
    }

	func presentConfirmation(phoneNumber: String, completion: (() -> Void)?) {
        self.hideLoading()
        let assembly = AuthConfirmationAssembly(phoneNumber: phoneNumber, onAuthorize: completion)
        let controller = assembly.makeModule()
        controller.modalPresentationStyle = .fullScreen

        self.present(controller, animated: true, completion: nil)
    }
}

extension AuthViewController: AuthViewDelegate {
    func authView(_ view: AuthView, didRequestAction viewModel: AuthViewModel) {
        self.presenter.submitAction(viewModel: viewModel)
        self.showLoading()
    }

    func authViewDidRequestDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
