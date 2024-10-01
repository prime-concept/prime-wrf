import UIKit

final class MapFilterTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 21, right: 21)
        static let itemHeight: CGFloat = 48
        static let itemTintColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
    }

    private lazy var itemView = MapFilterItemView()

    override var isSelected: Bool {
        didSet {
            self.accessoryType = self.isSelected ? .checkmark : .none
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with model: MapFilterItemViewModel) {
        self.itemView.title = model.title
    }

    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.tintColor = Appearance.itemTintColor

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.itemInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.itemInsets.right)
            make.height.equalTo(Appearance.itemHeight)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
