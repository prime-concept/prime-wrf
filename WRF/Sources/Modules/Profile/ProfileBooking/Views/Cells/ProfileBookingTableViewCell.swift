import UIKit

final class ProfileBookingTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 15, right: 15)
        static let itemHeight: CGFloat = 95
    }

    private lazy var itemView = ProfileBookingItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    // MARK: - Public API

    func configure(with model: BookingItemViewModel) {
        self.itemView.name = model.restaurant.title
        self.itemView.address = model.restaurant.address
        self.itemView.date = model.dateText
        self.itemView.guests = model.guests
        self.itemView.imageURL = model.restaurant.images.first?.image
    }

    // MARK: - Private API

    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

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
