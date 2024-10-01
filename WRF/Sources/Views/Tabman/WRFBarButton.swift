import Tabman
import UIKit

final class WRFBarButton: TMBarButton {
    struct Appearance: Codable {
        var tabBarTintColor = Palette.shared.textSecondary
        var tabBarButtonColor = Palette.shared.gray
        var tabBarButtonSelectedColor = Palette.shared.textPrimary
        var tabBarEditorLineHeight: CGFloat = 17

        var itemLabelOffset: CGFloat = 10

        var badgeLabelColor = Palette.shared.danger
        var badgeLabelTextColor = Palette.shared.white
        var badgeLabelTextInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        var badgeLabelCornerRadius: CGFloat = 6
    }

    private var appearance: Appearance

    var textAlignment: NSTextAlignment = .center {
        didSet {
            self.itemLabel.textAlignment = self.textAlignment
        }
    }

    var badgeCount: Int = 0 {
        didSet {
            self.badgeLabel.text = "\(self.badgeCount)"
            self.badgeLabel.isHidden = self.badgeCount == 0
        }
    }

    private lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.wrfFont(ofSize: 15)
        label.textColorThemed = appearance.tabBarTintColor
        return label
    }()

    private lazy var badgeLabel: UILabel = {
        let label = PaddingLabel()
        label.font = UIFont.wrfFont(ofSize: 10, weight: .bold)
        label.backgroundColorThemed = self.appearance.badgeLabelColor
        label.textColorThemed = self.appearance.badgeLabelTextColor
        label.insets = self.appearance.badgeLabelTextInsets
        label.layer.cornerRadius = self.appearance.badgeLabelCornerRadius
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()

    private lazy var badgeContainer = UIView()

    required init(for item: TMBarItemable, intrinsicSuperview: UIView?) {
        self.appearance = ApplicationAppearance.appearance()
        super.init(for: item, intrinsicSuperview: intrinsicSuperview)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout(in view: UIView) {
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(self.itemLabel)
        view.addSubview(self.badgeLabel)
        view.addSubview(self.badgeContainer)

        self.itemLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(appearance.itemLabelOffset)
            make.centerX.equalToSuperview()
        }
        self.badgeLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.itemLabel.snp.trailing)
            make.bottom.equalTo(self.itemLabel.snp.top).offset(5)
        }
        self.badgeContainer.snp.makeConstraints { make in
            make.top.equalTo(self.itemLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }

        self.itemLabel.textColorThemed = appearance.tabBarTintColor
        self.itemLabel.font = UIFont.wrfFont(ofSize: 15)
    }

    override func layoutBadge(_ badge: TMBadgeView, in view: UIView) {
        badge.tintColor = .clear
//        badge.textColor = appearance.tabBarTintColor
        badge.font = UIFont.wrfFont(ofSize: 10, weight: .medium)
        self.badgeContainer.addSubview(badge)

        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func populate(for item: TMBarItemable) {
        super.populate(for: item)
        self.itemLabel.attributedText = LineHeightStringMaker.makeString(
            item.title ?? "",
            editorLineHeight: appearance.tabBarEditorLineHeight,
            font: UIFont.wrfFont(ofSize: 15),
            alignment: self.textAlignment
        )
    }

    override func update(for selectionState: TMBarButton.SelectionState) {
        super.update(for: selectionState)
        switch selectionState {
        case .selected:
            self.itemLabel.textColorThemed = appearance.tabBarButtonSelectedColor
//            self.badge.textColorThemed = appearance.tabBarButtonSelectedColor
        case .unselected:
            self.itemLabel.textColorThemed = appearance.tabBarTintColor
//            self.badge.textColorThemed = appearance.tabBarTintColor
        default:
            break
        }
    }
}
