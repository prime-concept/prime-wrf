import SnapKit
import UIKit

final class MapRestaurantsTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 13, right: 13)
        static let itemHeight: CGFloat = 99

        static let itemInnerInset: CGFloat = 3
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = MapRestaurantItemView.Appearance().cornerRadius
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    private lazy var itemView = MapRestaurantItemView()

    override var isSelected: Bool {
        didSet {
            self.containerView.layer.borderWidth = self.isSelected ? 1 : 0
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.itemView.clear()
        self.containerView.layer.borderWidth = 0
    }

    func configure(with viewModel: MapRestaurantViewModel, isSmall: Bool = false) {
        self.itemView.title = viewModel.title
        self.itemView.imageURL = viewModel.imageURL
        self.itemView.isSmall = isSmall
        self.itemView.rating = viewModel.rating
        self.itemView.ratingText = viewModel.assessmentsCountText
        self.itemView.price = viewModel.price
        self.itemView.isRatingHidden = viewModel.rating == 0
        itemView.logoURL = viewModel.logoURL

        // Ignore schedule from backend when restaurant is closed
        self.itemView.addTimeLabels(
            viewModel.isClosed ? [] : viewModel.schedule,
            hasDelivery: viewModel.hasDelivery,
            isClosed: viewModel.isClosed
        )

        if viewModel.hasDelivery {
            self.itemView.deliveryTime = viewModel.deliveryTime
        } else {
            self.itemView.distance = viewModel.distanceText
        }
    }

    private func setupView() {
        self.backgroundColor = .clear
        self.selectionStyle = .none

        self.contentView.addSubview(self.containerView)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.itemInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.itemInsets.right)
            make.height.equalTo(Appearance.itemHeight)
            make.bottom.lessThanOrEqualToSuperview()
        }
        self.containerView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Appearance.itemInnerInset)
        }
    }
}
