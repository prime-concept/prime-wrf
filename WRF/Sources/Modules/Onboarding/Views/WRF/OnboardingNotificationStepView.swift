import UIKit
import UserNotifications

extension OnboardingNotificationStepView {
    struct Appearance {
        let buttonHeight = 39
        let buttonFont = UIFont.wrfFont(ofSize: 14)

        let headerHeight: CGFloat = 220
        let cornerRadius: CGFloat = 8

        let notificationButtonTitleColor = UIColor.black
        let notificationButtonTitleDisabledColor = UIColor.gray
        let notificationButtonBackColor = UIColor.white

        let nextButtonTitleColor = UIColor.white
        let nextButtonBackColor = UIColor.white.withAlphaComponent(0.3)

        let stackSpacing: CGFloat = 6
        let stackInsets = LayoutInsets(
            left: 15,
            bottom: PGCMain.shared.featureFlags.onboarding.buttonsInsetBottom,
            right: 15
        )

        let overlayColor = UIColor.black.withAlphaComponent(0.4)
    }
}

final class OnboardingNotificationStepView: UIView {
    let appearance: Appearance

    weak var delegate: OnboardingViewDelegate?

    var isNotificationButtonEnabled: Bool = true {
        didSet {
            self.notificationButton.isEnabled = self.isNotificationButtonEnabled
        }
    }

    private lazy var backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "onboarding-step-first"))

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
    }()

    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Включить уведомления", for: .normal)
        button.setTitleColor(self.appearance.notificationButtonTitleColor, for: .normal)
        button.setTitleColor(self.appearance.notificationButtonTitleDisabledColor, for: .disabled)
        button.titleLabel?.font = self.appearance.buttonFont
        button.backgroundColor = self.appearance.notificationButtonBackColor
        button.addTarget(self, action: #selector(self.askForNotifications), for: .touchUpInside)
        button.isEnabled = self.isNotificationButtonEnabled
        return button
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Далее", for: .normal)
        button.setTitleColor(self.appearance.nextButtonTitleColor, for: .normal)
        button.titleLabel?.font = self.appearance.buttonFont
        button.backgroundColor = self.appearance.nextButtonBackColor
        button.addTarget(self, action: #selector(self.nextClick), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.notificationButton, self.nextButton])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackSpacing
        return stackView
    }()

    private lazy var headerView: OnboardingHeaderView = {
        let header = OnboardingHeaderView()
        header.closeButton.addTarget(self, action: #selector(self.dismissOnboarding), for: .touchUpInside)
        return header
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private api

    @objc
    private func askForNotifications() {
        self.delegate?.onboardingViewDidRequestNotificationPermission()
    }

    @objc
    private func nextClick() {
        self.delegate?.onboardingViewDidRequestNextPage()
    }

    @objc
    private func dismissOnboarding() {
        self.delegate?.onboardingViewDidRequestDismiss()
    }
}

extension OnboardingNotificationStepView: ProgrammaticallyDesignable {
    func setupView() {
        self.notificationButton.layer.cornerRadius = self.appearance.cornerRadius
        self.nextButton.layer.cornerRadius = self.appearance.cornerRadius

        self.headerView.text = PGCMain.shared.text.onboardingNotificationStep
    }

    func addSubviews() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.headerView)
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.headerHeight)
        }

        [self.notificationButton, self.nextButton].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(self.appearance.buttonHeight) }
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.stackInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.stackInsets.right)
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottomMargin)
                    .offset(-self.appearance.stackInsets.bottom)
            } else {
                make.bottom.equalToSuperview().offset(-self.appearance.stackInsets.bottom)
            }
        }
    }
}
