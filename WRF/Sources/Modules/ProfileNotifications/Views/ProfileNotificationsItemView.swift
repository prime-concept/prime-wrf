import SnapKit
import UIKit

extension ProfileNotificationsItemView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        let titleEditorLineHeight: CGFloat = 17
        let titleColor = UIColor.black
        let titleOffset = LayoutInsets(left: 14, right: 5)

        let switcherOnColor = UIColor.black
        let switcherOffColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        let switcherRightOffset: CGFloat = 21

        let height: CGFloat = 50
    }
}

final class ProfileNotificationsItemView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont
            )
        }
    }

    var isSelected: Bool = false {
        didSet {
            self.switcher.isOn = self.isSelected
        }
    }

    var onChange: ((Bool) -> Void)?

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: self.appearance.height)
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleColor
        return label
    }()

    private(set) lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.onTintColor = self.appearance.switcherOnColor
        switcher.backgroundColor = self.appearance.switcherOffColor
        switcher.addTarget(self, action: #selector(self.onSwitcherValueChange), for: .valueChanged)
        return switcher
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
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
        self.switcher.layer.cornerRadius = self.switcher.frame.height / 2
    }

    // MARK: - Private API

    @objc
    private func onSwitcherValueChange(_ switch: UISwitch) {
        self.onChange?(switcher.isOn)
    }
}

extension ProfileNotificationsItemView: ProgrammaticallyDesignable {
    public func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.switcher)
    }

    public func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.titleOffset.left)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(self.switcher.snp.leading).offset(-self.appearance.titleOffset.right)
        }

        self.switcher.translatesAutoresizingMaskIntoConstraints = false
        self.switcher.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.switcherRightOffset)
            make.centerY.equalToSuperview()
        }
    }
}
