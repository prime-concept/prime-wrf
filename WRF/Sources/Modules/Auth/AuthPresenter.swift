import UIKit

extension Notification.Name {
	static let signUpCaptchaRequired = Notification.Name("signUpCaptchaRequired")
}

protocol AuthPresenterProtocol {
    func submitAction(viewModel: AuthViewModel)
}

final class AuthPresenter: AuthPresenterProtocol {
    weak var viewController: AuthViewControllerProtocol?

	private let onAuthorize: (() -> Void)?

    private let primePassClientEndpoint: PrimePassClientEndpointProtocol
    private let primePassAuthorizationEndpoint: PrimePassAuthorizationEndpointProtocol

    init(
        primePassClientEndpoint: PrimePassClientEndpointProtocol,
        primePassAuthorizationEndpoint: PrimePassAuthorizationEndpointProtocol,
		onAuthorize: (() -> Void)?
    ) {
        self.primePassClientEndpoint = primePassClientEndpoint
        self.primePassAuthorizationEndpoint = primePassAuthorizationEndpoint
		self.onAuthorize = onAuthorize
    }

    func submitAction(viewModel: AuthViewModel) {
        switch viewModel.action {
        case .signIn(let phoneNumber):
            self.signIn(phoneNumber: phoneNumber)
				
        case .signUp(
            let firstName,
            let lastName,
            let birthday,
            let gender,
			let email,
            let phoneNumber,
			let captchaToken,
			let deviceId
        ):
            self.signUp(
                firstName: firstName,
                lastName: lastName,
                birthday: birthday,
                gender: gender,
				email: email,
                phoneNumber: phoneNumber,
				captchaToken: captchaToken,
				deviceId: deviceId
            )
        }
    }

    // MARK: - Private API

    private func signUp(
        firstName: String,
        lastName: String,
        birthday: String,
        gender: Gender?,
		email: String,
        phoneNumber: String,
		captchaToken: String?,
		deviceId: String?
	) {
		let request = PrimePassClientCreateRequest(
			name: firstName,
			surname: lastName,
			phone: phoneNumber,
			email: email,
			authorizationType: .phone,
			issueCard: true,
			birthday: birthday,
			gender: gender,
			captchaToken: captchaToken,
			deviceId: deviceId
		)

		DispatchQueue.global(qos: .userInitiated).promise {
			self.primePassClientEndpoint.create(request: request).result
		}.done { response in
			switch response.status {
				case .ok:
					self.signIn(phoneNumber: phoneNumber)
				case .error:
					self.viewController?.hideLoading()
					print("auth presenter: response with error \(response.error.debugDescription)")

					if response.error?.message == "Captcha token not specified" {
						DebugUtils.shared.alert(title: "Необходимо ввести Captcha", action: "ОК") {
							NotificationCenter.default.post(.signUpCaptchaRequired)
						}
						return
					}

					type(of: self).showError(in: self.viewController, errorMessage: response.error?.message)
				default:
					return
			}
		}.catch { error in
			print("auth presenter: error while sign up = \(error)")
		}
	}

    private func signIn(phoneNumber: String) {
        let request = PrimePassAuthorizationRequest(
            login: phoneNumber,
            password: nil,
            authorizationType: .phone
        )

        DispatchQueue.global(qos: .userInitiated).promise {
            self.primePassAuthorizationEndpoint.retrieve(request: request).result
        }.done { response in
            switch response.status {
            case .ok:
					self.viewController?.presentConfirmation(
						phoneNumber: phoneNumber,
						completion: self.onAuthorize
					)
            case .error:
                type(of: self).showError(in: self.viewController, errorMessage: response.error?.message)
                print("auth presenter: response with error \(response.error.debugDescription)")
            default:
                return
            }
        }.ensure {
            self.viewController?.hideLoading()
        }.catch { error in
            print("auth presenter: error while sign in = \(error)")
        }
    }

    private static func showError(in viewController: AuthViewControllerProtocol?, errorMessage: String?) {
        if let errorMessage = errorMessage,
           let error = self.parseError(from: errorMessage) {
            viewController?.showError(error)
        } else {
            viewController?.showError(.unrecognized)
        }
    }

    private static func parseError(from message: String) -> AuthError? {
        // Dirty errors parsing cause backend guys couldn't send errors in a correct way
        if message == "Can\'t find specified login." {
            return .userNotFound
        } else if message == "Client with specified phone already exist." {
            return .userAlreadyExists
        }

        return nil
    }
}
