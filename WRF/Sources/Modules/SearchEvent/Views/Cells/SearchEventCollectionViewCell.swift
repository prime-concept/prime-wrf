import SnapKit
import UIKit

protocol SearchEventCollectionViewCellDelegate: AnyObject {
    func searchEventCollectionViewCell(
        _ cell: SearchEventCollectionViewCell,
        didFavorite event: SearchEventViewModel
    )
}

final class SearchEventCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let itemHeight: CGFloat = 200
    }

    weak var delegate: SearchEventCollectionViewCellDelegate?

    private var model: SearchEventViewModel?

    private lazy var itemView: EventCellCapable = {
        let view: EventCellCapable = PGCMain.shared.featureFlags.searching.useEventItemSmallImageView
            ? EventCarouselItemView()
            : EventItemView()
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

    func configure(with model: SearchEventViewModel) {
        self.model = model

        itemView.update(
            with: EventCellViewModel(
                id: "\(model.id)",
                imageURL: model.imageURL,
                date: model.date,
                title: model.title,
                subtitle: model.description,
                isFavorite: model.isFavorite
            )
        )
        itemView.nearestRestaurant = model.restaurantTitle
    }

    // MARK: - Private API

    @objc
    private func favoriteClicked() {
        guard let model = self.model else {
            return
        }
        self.delegate?.searchEventCollectionViewCell(self, didFavorite: model)
    }

    private func setupView() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Appearance.itemHeight)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}
