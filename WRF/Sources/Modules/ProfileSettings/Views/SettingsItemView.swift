import SnapKit
import UIKit

extension SettingsItemView {
    struct Appearance: Codable {
        var itemTitleColor = Palette.shared.textPrimary
        var itemTitleEditorLineHeight: CGFloat = 17

        var iconSize = CGSize(width: 44, height: 44)

        var stackSpacing: CGFloat = 0
    }
}

final class SettingsItemView: UIView {
    let appearance: Appearance

    private lazy var iconImageView = UIImageView()

    private lazy var itemTitle: UILabel = {
        let label = UILabel()
        label.textColorThemed = self.appearance.itemTitleColor
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.itemTitle])
        stack.axis = .horizontal
        stack.spacing = self.appearance.stackSpacing
        return stack
    }()

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
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

    func configure(with setting: Setting) {
        self.itemTitle.font = setting.type == .forPartners
            ? UIFont.wrfFont(ofSize: 15, weight: .medium)
            : UIFont.wrfFont(ofSize: 15, weight: .light)
        self.itemTitle.attributedText = LineHeightStringMaker.makeString(
            setting.title,
            editorLineHeight: self.appearance.itemTitleEditorLineHeight,
            font: setting.type == .forPartners
                ? UIFont.wrfFont(ofSize: 15, weight: .medium)
                : UIFont.wrfFont(ofSize: 15, weight: .light)
        )
        if let icon = setting.icon {
            self.stackView.insertArrangedSubview(self.iconImageView, at: 0)
            self.iconImageView.image = icon
        }
    }
}

extension SettingsItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.iconImageView.image = #imageLiteral(resourceName: "settings-logout")
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        self.iconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.iconSize)
        }
    }
}
