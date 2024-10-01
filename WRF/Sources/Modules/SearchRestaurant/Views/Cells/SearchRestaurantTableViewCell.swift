import SnapKit
import UIKit

final class SearchRestaurantTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 15, right: 15)
        static let itemHeight: CGFloat = 95
    }

    private lazy var itemView = MapRestaurantItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with model: SearchRestaurantViewModel, isSmall: Bool = false) {
        self.itemView.title = model.title
        self.itemView.imageURL = model.imageURL
        self.itemView.logoURL = model.logoURL
        self.itemView.isSmall = isSmall
        self.itemView.price = model.price
        self.itemView.rating = model.rating
        self.itemView.ratingText = model.assessmentsCountText
        self.itemView.isRatingHidden = model.rating == 0

        // Ignore schedule from backend when restaurant is closed
        self.itemView.addTimeLabels(
            model.isClosed ? [] : model.schedule,
            hasDelivery: model.hasDelivery,
            isClosed: model.isClosed
        )

        if model.hasDelivery {
            self.itemView.deliveryTime = model.deliveryTime
        } else {
            self.itemView.distance = model.distance
        }
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
