import CoreLocation
import UIKit

extension OnboardingGeolocationStepView {
    struct Appearance {
        let buttonHeight = 39
        let buttonFont = UIFont.wrfFont(ofSize: 14)

        let headerHeight: CGFloat = 220
        let cornerRadius: CGFloat = 8
        let editorLineHeight: CGFloat = 23

        let stackSpacing: CGFloat = 6
        let stackInsets = LayoutInsets(
            left: 15,
            bottom: PGCMain.shared.featureFlags.onboarding.buttonsInsetBottom,
            right: 15
        )

        let overlayColor = UIColor.black.withAlphaComponent(0.4)

        let geolocationButtonTitleColor = UIColor.black
        let geolocationButtonDisabledTitleColor = UIColor.gray
        let geolocationButtonBackColor = UIColor.white

        let nextButtonTitleColor = UIColor.white
        let nextButtonBackColor = UIColor.white.withAlphaComponent(0.3)
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

    private lazy var backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "onboarding-step-second"))

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
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
    private func askForGeolocation() {
        self.delegate?.onboardingViewDidRequestLocationPermission()
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

extension OnboardingGeolocationStepView: ProgrammaticallyDesignable {
    func setupView() {
        self.geolocationButton.layer.cornerRadius = self.appearance.cornerRadius
        self.nextButton.layer.cornerRadius = self.appearance.cornerRadius

        self.headerView.text = PGCMain.shared.text.onboardingGeolocationStep
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

        [self.geolocationButton, self.nextButton].forEach {
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
