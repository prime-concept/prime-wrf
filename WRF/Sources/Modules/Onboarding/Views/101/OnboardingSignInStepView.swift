import UIKit

extension OnboardingSignInStepView {
    struct Appearance {
        let buttonFont = UIFont.wrfFont(ofSize: 14)

        let cornerRadius: CGFloat = 5

        let signInTitleColor = UIColor.white
        let signInBackColor = UIColor(
            red: 0.784,
            green: 0.678,
            blue: 0.49,
            alpha: 1
        )

        let nextButtonTitleColor = ApplicationAppearance.mainColor
        let nextButtonBackColor = UIColor.white

        let gradientColors = [
            UIColor(red: 0.725, green: 0.218, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0.142, green: 0.036, blue: 0, alpha: 1).cgColor
        ]
        let gradientLocations: [NSNumber] = [0, 1]
        let gradientStartPoint = CGPoint(x: 0.5, y: 0.25)
        let gradientEndPoint = CGPoint(x: 0.5, y: 0.75)

        let signInHeight: CGFloat = 31
        let signInInsets = LayoutInsets(
            top: 69, left: 18,
            bottom: PGCMain.shared.featureFlags.onboarding.buttonsInsetBottom,
            right: 18
        )

        let closeColor = UIColor.white.withAlphaComponent(0.8)
        let closeInsets = LayoutInsets(right: 10)
        let closeSize = CGSize(width: 44, height: 44)
    }
}

final class OnboardingSignInStepView: UIView {
    let appearance: Appearance

    weak var delegate: OnboardingViewDelegate?

    private lazy var onboardingMainView: OnboardingMainView = {
        var appearance = OnboardingMainView.Appearance()
        appearance.image = #imageLiteral(resourceName: "onboarding-step-third")
        // swiftlint:disable:next line_length
        appearance.descriptionText = "Сохраняйте в личном кабинете ваши любимые\nрестораны и блюда, а также смотрите всю\nисторию ваших заказов"
        return OnboardingMainView(appearance: appearance)
    }()

    private lazy var overlayGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = self.appearance.gradientColors
        layer.locations = self.appearance.gradientLocations
        layer.startPoint = self.appearance.gradientStartPoint
        layer.endPoint = self.appearance.gradientEndPoint
        return layer
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

    private(set) lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        button.tintColor = self.appearance.closeColor
        button.addTarget(
            self,
            action: #selector(self.dismissOnboarding),
            for: .touchUpInside
        )
        return button
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

    override func layoutSubviews() {
        super.layoutSubviews()

        if overlayGradientLayer.superlayer == nil {
            layer.insertSublayer(overlayGradientLayer, at: 0)
        }

        overlayGradientLayer.frame = bounds
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
    }

    func addSubviews() {
        self.addSubview(self.onboardingMainView)
        self.addSubview(self.signInButton)
        self.addSubview(self.closeButton)
    }

    func makeConstraints() {
        self.onboardingMainView.translatesAutoresizingMaskIntoConstraints = false
        self.onboardingMainView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }

        self.signInButton.snp.makeConstraints { make in
            make.top
                .equalTo(self.onboardingMainView.snp.bottom)
                .offset(self.appearance.signInInsets.top)
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

        self.closeButton.snp.makeConstraints { make in
           if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.topMargin)
            } else {
                make.top.equalToSuperview()
            }
            make.trailing.equalToSuperview().offset(-self.appearance.closeInsets.right)
            make.size.equalTo(self.appearance.closeSize)
        }
    }
}

