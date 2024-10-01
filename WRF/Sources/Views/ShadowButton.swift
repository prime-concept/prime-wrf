import SnapKit
import UIKit

extension ShadowButton {
    struct Appearance {
        var mainFont = UIFont.wrfFont(ofSize: 17)
        var mainTextColor = Palette.shared.textPrimary
        let mainSelectedTextColor = Palette.shared.textPrimaryInverse
        var mainEditorLineHeight: CGFloat = 18
        var selectedBackgroundColor = Palette.shared.buttonAccent
        var insets = LayoutInsets(left: 0, right: 0)
    }
}

class ShadowButton: ShadowViewControl {
    let appearance: Appearance

    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.mainLabel])
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    private(set) lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.textColorThemed = self.appearance.mainTextColor
        return label
    }()

    private(set) lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var title: String? {
        didSet {
            self.mainLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.mainEditorLineHeight,
                font: self.appearance.mainFont
            )
            self.mainLabel.sizeToFit()
        }
    }

    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set {
            self.mainLabel.textColorThemed = newValue
                ? self.appearance.mainSelectedTextColor
                : self.appearance.mainTextColor
            super.isSelected = newValue
        }
    }

    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            self.alpha = newValue ? 1.0 : 0.5
            super.isEnabled = newValue
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = self.mainLabel.intrinsicContentSize
        return CGSize(
            width: size.width + self.appearance.insets.left + self.appearance.insets.right,
            height: size.height
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
        self.appearance = appearance

        var superAppearance = ShadowViewControl.Appearance()
        superAppearance.selectedBackgroundColor = self.appearance.selectedBackgroundColor
        super.init(frame: frame, appearance: superAppearance)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    func setImage(_ image: UIImage?) {
        guard image != nil else {
            self.stackView.removeArrangedSubview(self.iconImageView)
            self.iconImageView.removeFromSuperview()
            return
        }
        self.iconImageView.image = image
        self.stackView.insertArrangedSubview(self.iconImageView, at: 0)
    }

    // MARK: - ProgrammaticallyDesignable

    override func addSubviews() {
        super.addSubviews()
        self.addSubview(self.stackView)
    }

    override func makeConstraints() {
        super.makeConstraints()

        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
    }
}
