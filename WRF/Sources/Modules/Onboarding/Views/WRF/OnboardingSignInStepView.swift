import UIKit

extension OnboardingSignInStepView {
    struct Appearance {
        let buttonFont = UIFont.wrfFont(ofSize: 14)

        let headerHeight: CGFloat = 220
        let cornerRadius: CGFloat = 8
        let editorLineHeight: CGFloat = 23

        let signInHeight: CGFloat = 39
        let signInInsets = LayoutInsets(
            left: 15,
            bottom: PGCMain.shared.featureFlags.onboarding.buttonsInsetBottom,
            right: 15
        )
        let signInTitleColor = UIColor.black
        let signInBackColor = UIColor.white

        let overlayColor = UIColor.black.withAlphaComponent(0.4)
    }
}

final class OnboardingSignInStepView: UIView {
    let appearance: Appearance

    weak var delegate: OnboardingViewDelegate?

    private lazy var backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "onboarding-step-third"))

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
    }()

    private lazy var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(self.appearance.signInTitleColor, for: .normal)
        button.titleLabel?.font = self.appearance.buttonFont
        button.backgroundColor = self.appearance.signInBackColor
        button.addTarget(self, action: #selector(self.signIn), for: .touchUpInside)
        return button
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
    private func signIn() {
        self.delegate?.onboardingViewDidRequestSignUp()
    }

    @objc
    private func dismissOnboarding() {
        self.delegate?.onboardingViewDidRequestDismiss()
    }
}

extension OnboardingSignInStepView: ProgrammaticallyDesignable {
    func setupView() {
        self.signInButton.layer.cornerRadius = self.appearance.cornerRadius

        self.headerView.text = PGCMain.shared.text.onboardingSignInStep
    }

    func addSubviews() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.headerView)
        self.addSubview(self.signInButton)
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

        self.signInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.signInInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.signInInsets.right)
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottomMargin)
                    .offset(-self.appearance.signInInsets.bottom)
            } else {
                make.bottom.equalToSuperview().offset(-self.appearance.signInInsets.bottom)
            }
            make.height.equalTo(self.appearance.signInHeight)
        }
    }
}
