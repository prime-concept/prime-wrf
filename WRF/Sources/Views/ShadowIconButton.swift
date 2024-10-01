import SnapKit
import UIKit

extension ShadowIconButton {
    struct Appearance: Codable {
        var mainTextColor = Palette.shared.textPrimary
        var mainEditorLineHeight: CGFloat = 16

        var leftInset: CGFloat = 15
        var rightInset: CGFloat = 15
        var spacing: CGFloat = 10
        var iconSize = CGSize(width: 24, height: 24)
        var shouldUseImage = true
    }
}

class ShadowIconButton: ShadowViewControl {
    let appearance: Appearance

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.wrfFont(ofSize: 13)
        label.textColorThemed = self.appearance.mainTextColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.iconImageView, self.mainLabel])
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = self.appearance.spacing
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var iconImageView = UIImageView()

    var iconImage: UIImage? {
        didSet {
            self.iconImageView.image = self.iconImage
        }
    }

    var title: String? {
        didSet {
            self.mainLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.mainEditorLineHeight,
                font: UIFont.wrfFont(ofSize: 13)
            )
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)
    }

    // MARK: - ProgrammaticallyDesignable

    override func setupView() {
//        self.iconImageView.isHidden = !self.appearance.shouldUseImage
    }
    override func addSubviews() {
        super.addSubviews()
        self.addSubview(self.stackView)
    }

    override func makeConstraints() {
        super.makeConstraints()

        self.mainLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconSize)
        }
    }
}
