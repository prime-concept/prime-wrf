import UIKit

extension Notification.Name {
    static let login = Notification.Name(rawValue: "login")
}

protocol AuthConfirmationPresenterProtocol {
    func submitAction(viewModel: AuthConfirmationViewModel)
    func requestCode()
}

final class AuthConfirmationPresenter: AuthConfirmationPresenterProtocol {
    weak var viewController: AuthConfirmationViewControllerProtocol?

    private let primePassAuthorizationEndpoint: PrimePassAuthorizationEndpointProtocol
    private let notificationTokenRegisterService: NotificationsTokenRegisterServiceProtocol
    private let authService: AuthServiceProtocol
    private let phoneNumber: String
	private let onAuthorize: (() -> Void)?

    init(
        phoneNumber: String,
        primePassAuthorizationEndpoint: PrimePassAuthorizationEndpointProtocol,
        notificationTokenRegisterService: NotificationsTokenRegisterServiceProtocol,
        authService: AuthServiceProtocol,
		onAuthorize: (() -> Void)?
    ) {
        self.phoneNumber = phoneNumber
        self.primePassAuthorizationEndpoint = primePassAuthorizationEndpoint
        self.notificationTokenRegisterService = notificationTokenRegisterService
        self.authService = authService
		self.onAuthorize = onAuthorize
    }

    func submitAction(viewModel: AuthConfirmationViewModel) {
        let request = PrimePassAuthorizationRequest(
            login: self.phoneNumber,
            password: viewModel.password,
            authorizationType: .phone
        )

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.primePassAuthorizationEndpoint.create(request: request).result
        }.done(on: queue) { response in
            switch response.status {
            case .ok:
                guard let data = response.data, let token = data.token, let hostessToken = data.hostessToken else {
                    print("auth confirmation presenter: incorrect data")
                    return
                }

                self.authService.saveAuthorization(data: (data.userID, token, hostessToken))
                self.notificationTokenRegisterService.update(userID: data.userID)
                
				NotificationCenter.default.post(name: .login, object: nil)
				self.onAuthorize?()

                DispatchQueue.main.async {
                    self.viewController?.dismissAuthorization()
                }
            case .error:
                DispatchQueue.main.async {
                    type(of: self).showError(in: self.viewController, errorMessage: response.error?.message)
                }
                print("auth confirmation presenter: response with error \(response.error.debugDescription)")
            default:
                return
            }
        }.ensure {
            self.viewController?.hideLoading()
        }.catch { error in
            print("auth confirmation presenter: error while action = \(error)")
        }
    }

    func requestCode() {
        let request = PrimePassAuthorizationRequest(
            login: self.phoneNumber,
            password: nil,
            authorizationType: .phone
        )

        DispatchQueue.global(qos: .userInitiated).promise {
            self.primePassAuthorizationEndpoint.retrieve(request: request).result
        }.done { response in
            switch response.status {
            case .ok:
                self.viewController?.updateSMSCodeStatus()
            case .error:
                print("auth confirmation presenter: response with error \(response.error.debugDescription)")
            default:
                return
            }
        }.ensure {
            self.viewController?.hideLoading()
        }.catch { error in
            print("auth confirmation presenter: error while request code = \(error)")
        }
    }

    private static func showError(in viewController: AuthConfirmationViewControllerProtocol?, errorMessage: String?) {
        if let errorMessage = errorMessage,
           let error = self.parseError(from: errorMessage) {
            viewController?.showError(error)
        } else {
            viewController?.showError(.unrecognized)
        }
    }

    private static func parseError(from message: String) -> AuthConfirmationError? {
        // Dirty errors parsing cause backend guys couldn't send errors in a correct way
        if message == "Invalid verification code." {
            return .invalidCode
        }

        return nil
    }
}
