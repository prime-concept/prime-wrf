import SnapKit
import UIKit

protocol FavoritesMultiEventCollectionViewCellDelegate: AnyObject {
    func eventMultipleCollectionViewCell(
        _ cell: FavoritesMultiEventCollectionViewCell ,
        didFavorite model: FavoritesEventViewModel
    )

    func eventMultipleItemSelected(
        _ cell: FavoritesMultiEventCollectionViewCell ,
        didSelect model: FavoritesEventViewModel
    )
}

final class FavoritesMultiEventCollectionViewCell: UICollectionViewCell, Reusable {
    static let minimumItemCount = 1

    enum Appearance {
        static let itemInset = LayoutInsets(left: 15, right: 15)
		static let itemSize = PGCMain.shared.featureFlags.events.eventCellSize
    }

    weak var delegate: FavoritesMultiEventCollectionViewCellDelegate?

    private lazy var itemView = EventMultipleItemView()

    var items: [FavoritesEventViewModel] = [] {
        didSet {
            self.itemView.updateEventCollectionView(delegate: self, dataSource: self)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    // MARK: - Private api

    private func setupView() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Appearance.itemSize.height)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension FavoritesMultiEventCollectionViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if self.items.count == EventMultipleCollectionViewCell.minimumItemCount {
            let subtractedWidth = Appearance.itemInset.left + Appearance.itemInset.right
            let width = UIScreen.main.bounds.width - subtractedWidth
            return CGSize(width: width, height: Appearance.itemSize.height)
        }
        return Appearance.itemSize
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let model = self.items[safe: indexPath.row] else {
            return
        }
        self.delegate?.eventMultipleItemSelected(self, didSelect: model)
    }
}

extension FavoritesMultiEventCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: FavoritesEventCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        if let event = self.items[safe: indexPath.row] {
            cell.configure(with: event)
        }
        return cell
    }
}

extension FavoritesMultiEventCollectionViewCell: FavoritesEventCollectionViewCellDelegate {
    func favoritesTableViewCell(
        _ cell: FavoritesEventCollectionViewCell,
        didFavorite event: FavoritesEventViewModel
    ) {
        self.delegate?.eventMultipleCollectionViewCell(self, didFavorite: event)
    }
}
