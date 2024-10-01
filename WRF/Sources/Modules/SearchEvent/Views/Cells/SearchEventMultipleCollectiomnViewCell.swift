import SnapKit
import UIKit

protocol SearchEventMultiCollectionViewCellDelegate: AnyObject {
    func searchEventMultipleCollectionViewCell(
        _ cell: SearchEventMultiCollectionViewCell ,
        didFavorite model: SearchEventViewModel
    )
    func searchEventMultipleCollectionViewCell(didSelect model: SearchEventViewModel)
}

final class SearchEventMultiCollectionViewCell: UICollectionViewCell, Reusable {
    static let minimumItemCount = 1

    enum Appearance {
        static let itemInset = LayoutInsets(left: 16, right: 16)
        static let itemSize = PGCMain.shared.featureFlags.events.eventCellSize
    }

    weak var delegate: SearchEventMultiCollectionViewCellDelegate?

    private lazy var itemView = EventMultipleItemView()

    var items: [SearchEventViewModel] = [] {
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
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Appearance.itemSize.height)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension SearchEventMultiCollectionViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.items[indexPath.row]
        self.delegate?.searchEventMultipleCollectionViewCell(didSelect: model)
    }
}

extension SearchEventMultiCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: SearchEventCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        if let event = self.items[safe: indexPath.row] {
            cell.configure(with: event)
        }
        return cell
    }
}

extension SearchEventMultiCollectionViewCell: SearchEventCollectionViewCellDelegate {
    func searchEventCollectionViewCell(
        _ cell: SearchEventCollectionViewCell,
        didFavorite event: SearchEventViewModel
    ) {
        self.delegate?.searchEventMultipleCollectionViewCell(self, didFavorite: event)
    }
}
