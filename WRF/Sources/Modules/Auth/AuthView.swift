import SnapKit
import Tabman
import UIKit

protocol AuthViewDelegate: AnyObject {
	func authViewDidRequestDismiss()
    func authView(_ view: AuthView, didRequestAction viewModel: AuthViewModel)
}

extension AuthView {
    struct Appearance {
        let logo = #imageLiteral(resourceName: "dark-logo")
        let logoInsetsSmallScreen = LayoutInsets(top: 16)
        let logoInsets = LayoutInsets(top: 51)

        let switchButtonFont = UIFont.wrfFont(ofSize: 17)
        let switchEditorLineHeight: CGFloat = 20
        let switchButtonInsets = LayoutInsets(left: 20, right: 20)
        let switchButtonHeight: CGFloat = 35

        let buttonsInset = LayoutInsets(top: 40, bottom: 25)
        let buttonSmallTopInset: CGFloat = 15
        let buttonsSpacing: CGFloat = 10

        let containerViewInsets = LayoutInsets(left: 30, right: 30)
        let headerHeight: CGFloat = 44
        let headerInsets = LayoutInsets(top: -20, left: 0, bottom: 0, right: 0)

        let tabBarWeight: CGFloat = 1
        let tabBarTintColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 20
        let titleLabelFont = UIFont.wrfFont(ofSize: 17)
        let titleLabelTextColor = Palette.shared.textPrimary
        let tabBarColorInsideProfile = Palette.shared.backgroundColor0

        let closeButtonColor = Palette.shared.gray
        let closeButtonInsets = LayoutInsets(right: 10)
        let closeButtonSize = CGSize(width: 44, height: 44)
        
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

enum AuthPage: Int {
    case signIn = 0
    case signUp = 1
}

final class AuthView: UIView {
    private static let signInButtonTag = AuthPage.signIn.rawValue
    private static let signUpButtonTag = AuthPage.signUp.rawValue

    weak var delegate: AuthViewDelegate?
    let appearance: Appearance
    private let isSmallScreen: Bool
    private let withHeader: Bool
    private let withLogo: Bool
    private let page: AuthPage

    private(set) lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()

    private(set) lazy var tabContainerView: UIView = {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.tabBarColorInsideProfile
        return view
    }()

    private lazy var containerView = UIView()

    private lazy var logoImageView = UIImageView(image: UIImage(named: PGCMain.shared.featureFlags.auth.shouldUseDarkLogo ? "dark-logo" : "light-logo"))

    private lazy var signInButton: ShadowButton = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.switchButtonFont
        appearance.mainEditorLineHeight = self.appearance.switchEditorLineHeight
        appearance.insets = self.appearance.switchButtonInsets

        let button = ShadowButton(appearance: appearance)
        button.title = "Вход"
        button.tag = AuthView.signInButtonTag
        button.addTarget(self, action: #selector(self.changeTab(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var signUpButton: ShadowButton = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.switchButtonFont
        appearance.mainEditorLineHeight = self.appearance.switchEditorLineHeight
        appearance.insets = self.appearance.switchButtonInsets

        let button = ShadowButton(appearance: appearance)
        button.title = "Регистрация"
        button.tag = AuthView.signUpButtonTag
        button.addTarget(self, action: #selector(self.changeTab(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.signInButton, self.signUpButton])
        stackView.spacing = self.appearance.buttonsSpacing
        return stackView
    }()

    private lazy var signInView: AuthSignInView = {
        let view = AuthSignInView()
        view.submitButton.addTarget(self, action: #selector(self.submitButtonClicked), for: .touchUpInside)

        return view
    }()

    private lazy var signUpView: AuthSignUpView = {
        let view = AuthSignUpView()
        view.submitButton.addTarget(self, action: #selector(self.submitButtonClicked), for: .touchUpInside)
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "darkgray-close"), for: .normal)
        button.tintColorThemed = self.appearance.closeButtonColor
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    var isSignInTabActive: Bool {
        return !self.signInView.isHidden
    }

    var isSignUpTabActive: Bool {
        return !self.signUpView.isHidden
    }

	private var signUpBlock: (() -> Void)?

    init(
        frame: CGRect = .zero,
        isSmallScreen: Bool,
        appearance: Appearance = ApplicationAppearance.appearance(),
        withHeader: Bool = true,
        withLogo: Bool = true,
        page: AuthPage = .signIn
    ) {
        self.appearance = appearance
        self.isSmallScreen = isSmallScreen
        self.withHeader = withHeader
        self.withLogo = withLogo
        self.page = page
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

		Notification.onReceive(.signUpCaptchaRequired) { [weak self] _ in
			self?.signUpBlock?()
			self?.signUpBlock = nil
		}
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showError(message: String) {
        if self.isSignInTabActive {
            self.signInView.showError(message: message)
        } else {
            self.signUpView.showError(message: message)
        }
    }

    // MARK: - Private API

    @objc
    private func changeTab(_ sender: ShadowButton) {
        let data: [(ShadowButton, UIView)] = [
            (self.signInButton, self.signInView),
            (self.signUpButton, self.signUpView)
        ]
        data.enumerated().forEach { (index, element) in
            element.0.isSelected = index == sender.tag
            element.1.isHidden = index != sender.tag
        }
        self.hideKeyboard()
    }

    @objc
    private func submitButtonClicked() {
        if self.isSignInTabActive {
            self.signInView.phoneTextField.errorMessage = nil

			let phoneNumber = self.signInView.phoneTextField.unformattedText
			let isValidNumber = self.signInView.phoneTextField.phoneNumberTextField.isValidNumber

			guard let phoneNumber = phoneNumber, isValidNumber else {
                self.signInView.phoneTextField.errorMessage = "Введите телефон"
                return
            }

            let viewModel = AuthViewModel(
                action: .signIn(phoneNumber: phoneNumber)
            )
            self.delegate?.authView(self, didRequestAction: viewModel)
            return
        }

        if self.isSignUpTabActive {
            self.signUpView.firstNameTextField.errorMessage = nil
            self.signUpView.lastNameTextField.errorMessage = nil
			self.signUpView.birthDateTextField.errorMessage = nil
            self.signUpView.genderTextField.errorMessage = nil
			self.signUpView.emailTextField.errorMessage = nil
			self.signUpView.phoneTextField.errorMessage = nil

            guard let firstName = self.signUpView.firstNameTextField.unformattedText, !firstName.isEmpty else {
                self.signUpView.firstNameTextField.errorMessage = "Введите имя"
                return
            }

            let lastName = self.signUpView.lastNameTextField.unformattedText ?? ""

			guard let date = self.signUpView.birthDate else {
				self.signUpView.birthDateTextField.errorMessage = "Укажите дату рождения"
				return
			}

			guard let gender = self.signUpView.gender else {
				self.signUpView.genderTextField.errorMessage = "Выберите пол"
				return
			}

			guard let email = self.signUpView.emailTextField.unformattedText, email.count > 0 else {
				self.signUpView.emailTextField.errorMessage = "Введите e-mail"
				return
			}

			guard email.isValidEmail() else {
				self.signUpView.emailTextField.errorMessage = "Некорректный e-mail"
				return
			}

            guard let phoneNumber = self.signUpView.phoneTextField.unformattedText, !phoneNumber.isEmpty else {
                self.signUpView.phoneTextField.errorMessage = "Введите телефон"
                return
            }

			func makeAuthViewModel(with token: String?) -> AuthViewModel {
				 AuthViewModel(
					action: .signUp(
						firstName: firstName,
						lastName: lastName,
						birthday: date.formatToBackend(),
						gender: gender,
						email: email,
						phoneNumber: phoneNumber,
						captchaToken: token,
						deviceId: UIDevice.current.identifierForVendor?.uuidString
					)
				)
			}

			self.requestCaptchaIfNeeded { token in
				let viewModel = makeAuthViewModel(with: token)
				self.delegate?.authView(self, didRequestAction: viewModel)
			}

			self.signUpBlock = { [weak self] in
				guard let self = self else { return }

				self.showCaptcha { token in
					let viewModel = makeAuthViewModel(with: token)
					self.delegate?.authView(self, didRequestAction: viewModel)
				}
			}
        }
    }

	private func requestCaptchaIfNeeded(_ completion: @escaping (String?) -> Void) {
		PrimePassContractorEndpoint.shared.settings().done { result in
			if result.data?.isCaptchaEnabled == true {
				self.showCaptcha(completion); return
			}
			completion(nil)
		}.catch { error in
			self.showCaptcha(completion)
		}
	}

	func showCaptcha(_ completion: @escaping (String?) -> Void) {
		let test = UserDefaults[bool: "CaptchaDebug"] ? "&test=true" : ""

		let token = UserDefaults[bool: "CaptchaProd"] ?
		"ysc1_IvXAUk53A7o8L3Tm1RwHcwl781ifP8OqZIyeyLrYb20ec462" :
		"ysc1_tiFVdiTX4KGNwFINrpoI4hNcTH7RViQ7dNvxs7hJ17fb84b5"

		let captchaViewController = CaptchaWebViewController(
			host: "https://smartcaptcha.yandexcloud.net/webview",
			secret: "\(token)\(test)",
            preferredHeight: 480 - 20 - 44
		)

		let curtain = CurtainViewController(with: UIStackView.vertical(
			captchaViewController.view
		))
		curtain.addChild(captchaViewController)

		captchaViewController.successHandler = { token in
			curtain.dismiss(animated: true) {
				completion(token)
			}
		}

		captchaViewController.errorHandler = { e in
			curtain.dismiss(animated: true) {
				completion(nil)
			}
		}
		curtain.present(animated: false)
	}

    @objc
    private func hideKeyboard() {
        self.endEditing(true)
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.authViewDidRequestDismiss()
    }
}

extension AuthView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor

        // Default values
        self.signInButton.isSelected = self.page == .signIn
        self.signUpButton.isSelected = self.page == .signUp
        self.signInView.isHidden = self.page == .signUp
        self.signUpView.isHidden = self.page == .signIn
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        if self.withHeader {
            self.containerView.addSubview(self.closeButton)
        }
        if self.withLogo {
            self.containerView.addSubview(self.logoImageView)
        }
        self.containerView.addSubview(self.buttonsStackView)
        self.containerView.addSubview(self.signInView)
        self.containerView.addSubview(self.signUpView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        if self.withHeader {
            self.closeButton.translatesAutoresizingMaskIntoConstraints = false
            self.closeButton.snp.makeConstraints { make in
                if #available(iOS 11.0, *) {
                    make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                } else {
                    make.top.equalToSuperview()
                }
                make.trailing.equalToSuperview().offset(-self.appearance.closeButtonInsets.right)
                make.size.equalTo(self.appearance.closeButtonSize)
            }
        }

        if self.withLogo {
            self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
            self.logoImageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()

                make.top
                    .equalTo(self.containerView.snp.top)
                    .offset(
                        (self.withHeader ? self.appearance.closeButtonSize.height : 0)
                        +
                        (self.isSmallScreen
                            ? self.appearance.logoInsetsSmallScreen.top
                            : self.appearance.logoInsets.top)
                    )
                make.size.equalTo(PGCMain.shared.featureFlags.auth.logoSize)
            }
        }

        self.signUpButton.translatesAutoresizingMaskIntoConstraints = false
        self.signUpButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.switchButtonHeight)
        }

        self.signInButton.translatesAutoresizingMaskIntoConstraints = false
        self.signInButton.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.switchButtonHeight)
        }

        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            if self.withLogo {
                make.top
                    .equalTo(self.logoImageView.snp.bottom)
                    .offset(self.appearance.buttonsInset.top)
            } else {
                make.top
                    .equalToSuperview()
                    .offset(self.appearance.buttonSmallTopInset)
            }
        }

        self.signUpView.translatesAutoresizingMaskIntoConstraints = false
        self.signUpView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.containerViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.containerViewInsets.right)
            make.top.equalTo(self.buttonsStackView.snp.bottom).offset(self.appearance.buttonsInset.bottom)
            make.bottom.equalToSuperview()
        }

        self.signInView.translatesAutoresizingMaskIntoConstraints = false
        self.signInView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.containerViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.containerViewInsets.right)
            make.top.equalTo(self.buttonsStackView.snp.bottom).offset(self.appearance.buttonsInset.bottom)
            make.bottom.equalToSuperview()
        }
    }
}
