import SnapKit
import UIKit

protocol FavoritesEventCollectionViewCellDelegate: AnyObject {
    func favoritesTableViewCell(
        _ cell: FavoritesEventCollectionViewCell,
        didFavorite event: FavoritesEventViewModel
    )
}

final class FavoritesEventCollectionViewCell: UICollectionViewCell, Reusable {
    weak var delegate: FavoritesEventCollectionViewCellDelegate?

    private var model: FavoritesEventViewModel?

    private lazy var itemView: EventCellCapable = {
        let view: EventCellCapable
		if PGCMain.shared.featureFlags.profile.shouldDisplayEventCarousel {
			view = EventCarouselItemView()
		} else {
			view = EventItemView()
		}

        view.favoriteControl.addTarget(self, action: #selector(self.favoriteClicked), for: .touchUpInside)
        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.model = nil
        self.itemView.clear()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with model: FavoritesEventViewModel) {
        self.model = model

		let cellViewModel = EventCellViewModel(
			id: model.id,
			imageURL: model.imageURL,
			date: model.date,
			title: model.title,
            subtitle: model.description,
			nearestRestaurant: model.nearestRestaurant,
			isFavorite: model.isFavorite
		)

		self.itemView.update(with: cellViewModel)
    }

    // MARK: - Private api

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
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
			make.height.equalTo(self.itemView.itemHeight)
        }
    }
}
