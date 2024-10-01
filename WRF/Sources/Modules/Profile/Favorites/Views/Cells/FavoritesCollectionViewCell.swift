import SnapKit
import UIKit

protocol FavoritesCollectionViewCellDelegate: AnyObject {
    func favoritesTableViewCell(
        _ cell: FavoritesCollectionViewCell,
        didFavorite event: FavoritesRestaurantViewModel
    )
}

final class FavoritesCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let itemInsets = LayoutInsets(left: 15, right: 15)
        static let itemHeight: CGFloat = 200
    }

    weak var delegate: FavoritesCollectionViewCellDelegate?

    private var model: FavoritesRestaurantViewModel?

    private lazy var itemView: FavoritesItemView = {
        let view = FavoritesItemView()
        view.favoriteControl.isUserInteractionEnabled = true
        view.favoriteControl.addTarget(self, action: #selector(self.favoriteClicked), for: .touchUpInside)
        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.itemView.clear()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with model: FavoritesRestaurantViewModel) {
        self.model = model

        self.itemView.title = model.title
        self.itemView.address = model.address
        self.itemView.distance = model.distanceText
        self.itemView.price = model.price
        self.itemView.rating = model.rating
        self.itemView.ratingText = model.assessmentsCountText
        self.itemView.imageURL = model.imageURL
        self.itemView.logoURL = model.logoURL
        self.itemView.isFavorite = model.isFavorite
    }

    // MARK: - Private API

    @objc
    private func favoriteClicked() {
        guard let model = self.model else {
            return
        }
        self.delegate?.favoritesTableViewCell(self, didFavorite: model)
    }

    private func setupView() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Appearance.itemInsets.left)
            make.trailing.equalToSuperview().offset(-Appearance.itemInsets.right)
			make.bottom.equalToSuperview().inset(12)
        }
    }
}
