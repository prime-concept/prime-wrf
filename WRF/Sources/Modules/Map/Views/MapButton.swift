import SnapKit
import UIKit

extension MapButton {
    struct Appearance {
        let borderColor = UIColor.white
        let borderWidth: CGFloat = 1
        let cornerRadius: CGFloat = 8

        var buttonColor = UIColor.black
        let badgeColor = UIColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        let badgeTextColor = UIColor.white
        let badgeFont = UIFont.wrfFont(ofSize: 10, weight: .bold)
        let badgeTextInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        let badgeCornerRadius: CGFloat = 5

        let badgeHeight: CGFloat = 13
        let badgeInsets = LayoutInsets(top: 8, right: 8)
    }
}

final class MapButton: UIView {
    let appearance: Appearance

    private lazy var backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        return UIVisualEffectView(effect: blurEffect)
    }()

    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = self.appearance.buttonColor
        return button
    }()

    private lazy var badgeLabel: UILabel = {
        let label = PaddingLabel()
        label.font = self.appearance.badgeFont
        label.backgroundColor = self.appearance.badgeColor
        label.textColor = self.appearance.badgeTextColor
        label.insets = self.appearance.badgeTextInsets
        label.layer.cornerRadius = self.appearance.cornerRadius
        label.layer.masksToBounds = true
        return label
    }()

    var image: UIImage? {
        didSet {
            let image = self.image?.withRenderingMode(.alwaysTemplate)
            self.button.setImage(image, for: .normal)
        }
    }

    var badgeCount: Int? {
        didSet {
            if let badgeCount = self.badgeCount {
                self.badgeLabel.text = "\(badgeCount)"
                self.badgeLabel.isHidden = false
            } else {
                self.badgeLabel.isHidden = true
            }
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

    func addTarget(target: Any?, action: Selector, for event: UIControl.Event) {
        self.button.addTarget(target, action: action, for: event)
    }
}

extension MapButton: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = false

        self.backgroundView.layer.masksToBounds = true
        self.backgroundView.layer.cornerRadius = self.appearance.cornerRadius
        self.backgroundView.layer.borderColor = self.appearance.borderColor.cgColor
        self.backgroundView.layer.borderWidth = self.appearance.borderWidth

        self.badgeLabel.isHidden = true
    }

    func addSubviews() {
        self.addSubview(self.backgroundView)
        self.addSubview(self.button)
        self.addSubview(self.badgeLabel)
    }

    func makeConstraints() {
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.badgeLabel.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.badgeHeight)
            make.centerX.equalToSuperview().offset(self.appearance.badgeInsets.right)
            make.centerY.equalToSuperview().offset(-self.appearance.badgeInsets.top)
        }
    }
}
