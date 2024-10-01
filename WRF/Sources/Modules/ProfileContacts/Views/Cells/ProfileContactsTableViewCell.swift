import SnapKit
import UIKit

final class ProfileContactsTableViewCell: UITableViewCell, Reusable {
    private enum Appearance {
        static let itemOffset = LayoutInsets(left: 15, right: 15)
        static let itemHeight: CGFloat = 37
    }

    private lazy var itemView = ProfileContactsItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    // MARK: - Public API

    func configure(with model: ProfileContactItemViewModel) {
        self.itemView.title = model.title
        self.itemView.value = model.value
    }

    // MARK: - Private API

    private func setupView() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Appearance.itemOffset.left)
            make.trailing.equalToSuperview().offset(-Appearance.itemOffset.right)
            make.centerY.equalToSuperview()
            make.height.equalTo(Appearance.itemHeight)
        }
    }
}
