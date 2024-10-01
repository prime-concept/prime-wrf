import SnapKit
import UIKit

protocol AuthConfirmationViewDelegate: AnyObject {
    func authConfirmationView(_ view: AuthConfirmationView, didRequestAction viewModel: AuthConfirmationViewModel)
    func authConfirmationViewDidRequestCode(_ view: AuthConfirmationView)
    func authConfirmationViewWantsClose(_ view: AuthConfirmationView)
}

extension AuthConfirmationView {
    struct Appearance {
        var logoSize = CGSize(width: 121, height: 33)
        let logo = #imageLiteral(resourceName: "dark-logo")
        let logoInsetsSmallScreen = LayoutInsets(top: 60)
        let logoInsets = LayoutInsets(top: 95)

        let titleFont = UIFont.wrfFont(ofSize: 17)
        var titleTextColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 20
        let titleInsets = LayoutInsets(top: 40, bottom: 33)

        let textFieldHeight: CGFloat = 55
        let textFieldInsets = LayoutInsets(left: 30, right: 30)

        let submitButtonHeight: CGFloat = 40
        let submitButtonAppearanceInsets = LayoutInsets(left: 20, right: 20)
        let submitInsets = LayoutInsets(top: 20, right: 30)
        let submitButtonFont = UIFont.wrfFont(ofSize: 14)
        let submitButtonEditorLineHeight: CGFloat = 16

        let sendAgainInsets = LayoutInsets(top: 20, left: 33)
        let sendAgainButtonAppearanceInsets = LayoutInsets(left: 16, right: 16)

        let closeButtonColor = Palette.shared.gray
        let closeButtonInsets = LayoutInsets(right: 10)
        let closeButtonSize = CGSize(width: 44, height: 44)
        
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class AuthConfirmationView: UIView {
    private static let sendAgainInterval = 60

    weak var delegate: AuthConfirmationViewDelegate?
    let appearance: Appearance
    private let isSmallScreen: Bool

    private var sendAgainTimer: Timer?

    private var secondsUntilAgain = 0 {
        didSet {
            if self.secondsUntilAgain > 0 {
                self.sendAgainButton.isEnabled = false
                self.sendAgainButton.title = "Отправить снова \(self.secondsUntilAgain)"
            } else {
                self.sendAgainTimer?.invalidate()
                self.sendAgainButton.isEnabled = true
                self.sendAgainButton.title = "Отправить снова"
            }
        }
    }

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        return view
    }()

    private lazy var containerView = UIView()

    private lazy var logoImageView = UIImageView(image: self.appearance.logo)

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Введите SMS",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        label.textColorThemed = self.appearance.titleTextColor
        return label
    }()

    private lazy var sendAgainButton: ShadowButton = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.submitButtonFont
        appearance.mainEditorLineHeight = self.appearance.submitButtonEditorLineHeight
        appearance.insets = self.appearance.sendAgainButtonAppearanceInsets
        let button = ShadowButton(appearance: appearance)
        button.isEnabled = false
        button.title = "Отправить снова"
        button.addTarget(self, action: #selector(self.sendAgainButtonClicked), for: .touchUpInside)

        if self.sendAgainTimer == nil {
            self.startTimer()
        }
        return button
    }()

    private lazy var codeTextField: FloatingTextField = {
        let textField = FloatingTextField()
        if #available(iOS 12.0, *) {
            textField.textContentType = .oneTimeCode
        }
        textField.placeholder = "Код из SMS"
        textField.title = "Код из SMS"
        return textField
    }()

    private lazy var submitButton: UIControl = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.submitButtonFont
        appearance.mainEditorLineHeight = self.appearance.submitButtonEditorLineHeight
        appearance.insets = self.appearance.submitButtonAppearanceInsets
        let button = ShadowButton(appearance: appearance)
        button.title = "Войти"
        button.addTarget(self, action: #selector(self.submitButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "darkgray-close"), for: .normal)
        button.tintColorThemed = self.appearance.closeButtonColor
        button.addTarget(self, action: #selector(self.closeButtonClicked), for: .touchUpInside)
        return button
    }()

    init(
        frame: CGRect = .zero,
        isSmallScreen: Bool,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
        self.appearance = appearance
        self.isSmallScreen = isSmallScreen
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateForNextSMS() {
        self.startTimer()
        self.codeTextField.text = nil
    }

    func showError(message: String) {
        self.codeTextField.errorMessage = message
    }

    // MARK: - Private API

    @objc
    private func submitButtonClicked() {
        self.codeTextField.errorMessage = nil

        guard let code = self.codeTextField.text, !code.isEmpty else {
            self.codeTextField.errorMessage = "Введите код"
            return
        }

        self.delegate?.authConfirmationView(self, didRequestAction: .init(password: code))
    }

    @objc
    private func sendAgainButtonClicked() {
        self.delegate?.authConfirmationViewDidRequestCode(self)
    }

    @objc
    private func hideKeyboard() {
        self.endEditing(true)
    }

    @objc
    private func closeButtonClicked() {
        self.delegate?.authConfirmationViewWantsClose(self)
    }

    private func startTimer() {
        self.sendAgainTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { [weak self] _ in
                self?.secondsUntilAgain -= 1
            }
        )
        self.secondsUntilAgain = AuthConfirmationView.sendAgainInterval
    }
}

extension AuthConfirmationView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
        logoImageView.contentMode = .scaleAspectFit
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.containerView)
        self.containerView.addSubview(self.closeButton)
        self.containerView.addSubview(self.logoImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.codeTextField)
        self.containerView.addSubview(self.submitButton)
        self.containerView.addSubview(self.sendAgainButton)
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

        self.closeButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.trailing.equalToSuperview().offset(-self.appearance.closeButtonInsets.right)
            make.size.equalTo(self.appearance.closeButtonSize)
        }

        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()

            if self.isSmallScreen {
                make.top.equalTo(self.appearance.logoInsetsSmallScreen.top)
            } else {
                make.top.equalTo(self.appearance.logoInsets.top)
            }
            make.size.equalTo(self.appearance.logoSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.logoImageView.snp.bottom).offset(self.appearance.titleInsets.top)
        }

        self.codeTextField.translatesAutoresizingMaskIntoConstraints = false
        self.codeTextField.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.textFieldHeight)
            make.leading.equalToSuperview().offset(self.appearance.textFieldInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.textFieldInsets.right)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.titleInsets.top)
        }

        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.top.equalTo(self.codeTextField.snp.bottom).offset(self.appearance.submitInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.submitInsets.right)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.submitButtonHeight)
        }

        self.sendAgainButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendAgainButton.snp.makeConstraints { make in
            make.top.equalTo(self.codeTextField.snp.bottom).offset(self.appearance.sendAgainInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.sendAgainInsets.left)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.submitButtonHeight)
        }
    }
}
