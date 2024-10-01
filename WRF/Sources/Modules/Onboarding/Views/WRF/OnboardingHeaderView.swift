import UIKit
import DeviceKit

extension OnboardingHeaderView {
    struct Appearance {
        enum Alignment {
            case leading(inset: CGFloat)
            case center
        }

        let headerColor = UIColor.white
        let headerLineCount = 0
        let headerFont = UIFont.wrfFont(ofSize: 17)
        let headerInsets = LayoutInsets(
            top: PGCMain.shared.featureFlags.onboarding.labelInsetTop, left: 20, right: 20
        )

        let closeColor = UIColor.white.withAlphaComponent(0.8)
        let editorLineHeight: CGFloat = 23

        let topContainerHeight: CGFloat = 44

        let logoAlignment: Alignment = PGCMain.shared.featureFlags.onboarding.needsCenteredLogo
        ? .center : .leading(inset: 20)

        let closeOffset: CGFloat = 10

        let gradientContainerAlpha: CGFloat = 0.6

        let logo = PGCMain.shared.resourceProvider.image(name: "light-logo")
        var logoSize = PGCMain.shared.featureFlags.onboarding.logoSize
    }
}

final class OnboardingHeaderView: UIView {
    let appearance: Appearance

    private lazy var topContainerView = UIView()
    private lazy var gradientContainerView: UIView = {
        let view = UIView()
        view.alpha = self.appearance.gradientContainerAlpha
        return view
    }()

    private lazy var logoImageView = UIImageView(image: self.appearance.logo)

    private(set) lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        button.tintColor = self.appearance.closeColor
        return button
    }()

    private(set) lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = self.appearance.headerLineCount
        label.font = self.appearance.headerFont
        label.textColor = self.appearance.headerColor
        return label
    }()

    private lazy var overlayGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        )
        return layer
    }()

    var text: String? {
        didSet {
            self.headerLabel.attributedText = LineHeightStringMaker.makeString(
                self.text ?? "",
                editorLineHeight: self.appearance.editorLineHeight,
                font: self.appearance.headerFont
            )
        }
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
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
        self.resetOverlayPosition()
    }

    // MARK: - Private api

    private func resetOverlayPosition() {
        self.overlayGradientLayer.frame = self.gradientContainerView.bounds
    }
}

extension OnboardingHeaderView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.gradientContainerView)
        self.gradientContainerView.layer.addSublayer(self.overlayGradientLayer)

        self.addSubview(self.topContainerView)
        self.topContainerView.addSubview(self.logoImageView)
        self.topContainerView.addSubview(self.closeButton)
        self.addSubview(self.headerLabel)
    }

    func makeConstraints() {
        self.gradientContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.gradientContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.topContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.topContainerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.topMargin)
                .inset(Device.current.hasSensorHousing ? 0 : 8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.topContainerHeight)
        }

        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.snp.makeConstraints { make in
            switch appearance.logoAlignment {
                case .leading(let inset):
                    make.leading.equalToSuperview().inset(inset)
                case .center:
                    make.centerX.equalToSuperview()
            }

            make.size.equalTo(self.appearance.logoSize)
            make.centerY.equalToSuperview()
        }

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.closeOffset)
            make.centerY.equalTo(self.logoImageView.snp.centerY)
        }

        self.headerLabel.translatesAutoresizingMaskIntoConstraints = false
        self.headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.headerInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.headerInsets.right)
            make.top.equalTo(self.topContainerView.snp.bottom).offset(self.appearance.headerInsets.top)
        }
    }
}
