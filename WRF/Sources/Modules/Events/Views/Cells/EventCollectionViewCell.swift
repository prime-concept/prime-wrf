import SnapKit
import UIKit

protocol EventCollectionViewCellDelegate: AnyObject {
    func favoritesTableViewCell(
        _ cell: EventCollectionViewCell,
        didFavorite event: EventItemViewModel
    )
}

final class EventCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let itemHeight: CGFloat = 200
    }

    weak var delegate: EventCollectionViewCellDelegate?

    private var model: EventItemViewModel?

    private lazy var itemView: EventItemView = {
        let view = EventItemView()
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

    func configure(with event: EventItemViewModel) {
        self.model = event

        self.itemView.title = event.title
        self.itemView.imageURL = event.imageURL
        self.itemView.date = event.date
        self.itemView.nearestRestaurant = event.restaurantTitle
        self.itemView.isFavorite = event.isFavorite
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
            make.height.equalTo(Appearance.itemHeight)
        }
    }
}
