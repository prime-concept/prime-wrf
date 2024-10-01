import UIKit

final class SettingsTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 5)
        static let itemHeight: CGFloat = 48
    }

    private lazy var itemView = SettingsItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with setting: Setting) {
        self.itemView.configure(with: setting)
    }

    private func setupView() {
        self.backgroundColor = .clear
        self.accessoryType = .disclosureIndicator

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.itemInsets.left)
            make.trailing.equalToSuperview()
            make.height.equalTo(Appearance.itemHeight)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
