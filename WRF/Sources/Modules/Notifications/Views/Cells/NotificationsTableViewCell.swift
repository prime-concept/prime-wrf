import UIKit

final class NotificationsTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 15, right: 15)
    }

    private lazy var itemView = NotificationsItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    // MARK: - Public API

    func configure(with model: NotificationViewModel) {
        self.itemView.message = model.message
        self.itemView.messageTime = model.messageTime
    }

    // MARK: - Private API

    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.clipsToBounds = true

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.itemInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.itemInsets.right)
            make.bottom.equalToSuperview()
        }
    }
}
