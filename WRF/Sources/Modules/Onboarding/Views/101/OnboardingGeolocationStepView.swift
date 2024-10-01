import CoreLocation
import UIKit

extension OnboardingGeolocationStepView {
    struct Appearance {
        let buttonHeight = 31
        let buttonFont = UIFont.wrfFont(ofSize: 14)

        let cornerRadius: CGFloat = 5

        let geolocationButtonTitleColor = UIColor.white
        let geolocationButtonDisabledTitleColor = UIColor.gray
        let geolocationButtonBackColor = UIColor(
            red: 0.784,
            green: 0.678,
            blue: 0.49,
            alpha: 1
        )

        let nextButtonTitleColor = ApplicationAppearance.mainColor
        let nextButtonBackColor = UIColor.white

        let stackSpacing: CGFloat = 10
        let stackInsets = LayoutInsets(
            top: 28, left: 18,
            bottom: PGCMain.shared.featureFlags.onboarding.buttonsInsetBottom,
            right: 18
        )

        let gradientColors = [
            UIColor(red: 0.725, green: 0.218, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0.142, green: 0.036, blue: 0, alpha: 1).cgColor
        ]
        let gradientLocations: [NSNumber] = [0, 1]
        let gradientStartPoint = CGPoint(x: 0.5, y: 0.25)
        let gradientEndPoint = CGPoint(x: 0.5, y: 0.75)
    }
}

final class OnboardingGeolocationStepView: UIView {
    let appearance: Appearance

    weak var delegate: OnboardingViewDelegate?

    var isGeolocationButtonEnabled: Bool = true {
        didSet {
            self.geolocationButton.isEnabled = self.isGeolocationButtonEnabled
        }
    }

    private lazy var onboardingMainView: OnboardingMainView = {
        var appearance = OnboardingMainView.Appearance()
        appearance.image = #imageLiteral(resourceName: "onboarding-step-second")
        appearance.descriptionText = "Автоматически определим ваш\nадрес для доставки блюд и\nпродуктов"
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

    private lazy var geolocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Включить геолокацию", for: .normal)
        button.setTitleColor(self.appearance.geolocationButtonTitleColor, for: .normal)
        button.setTitleColor(self.appearance.geolocationButtonDisabledTitleColor, for: .disabled)
        button.titleLabel?.font = self.appearance.buttonFont
        button.backgroundColor = self.appearance.geolocationButtonBackColor
        button.addTarget(self, action: #selector(self.askForGeolocation), for: .touchUpInside)
        button.isEnabled = self.isGeolocationButtonEnabled
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
        let stackView = UIStackView(arrangedSubviews: [self.geolocationButton, self.nextButton])
        stackView.axis = .vertical
        stackView.spacing = self.appearance.stackSpacing
        return stackView
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
    private func askForGeolocation() {
        self.delegate?.onboardingViewDidRequestLocationPermission()
    }

    @objc
    private func nextClick() {
        self.delegate?.onboardingViewDidRequestNextPage()
    }
}

extension OnboardingGeolocationStepView: ProgrammaticallyDesignable {
    func setupView() {
        self.geolocationButton.layer.cornerRadius = self.appearance.cornerRadius
        self.nextButton.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.onboardingMainView)
        self.addSubview(self.stackView)
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

        [self.geolocationButton, self.nextButton].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(self.appearance.buttonHeight) }
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top
                .equalTo(self.onboardingMainView.snp.bottom)
                .offset(self.appearance.stackInsets.top)
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

