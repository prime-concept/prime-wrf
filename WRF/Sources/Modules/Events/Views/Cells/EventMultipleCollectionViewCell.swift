import SnapKit
import UIKit

protocol EventMultipleCollectionViewCellDelegate: AnyObject {
    func eventMultipleCollectionViewCell(
        _ cell: EventMultipleCollectionViewCell ,
        didSelect event: EventItemViewModel
    )
    func eventMultipleCollectionViewCell(
        _ cell: EventMultipleCollectionViewCell ,
        didFavorite event: EventItemViewModel
    )
    func eventMultipleCollectionViewCell(
        _ cell: EventMultipleCollectionViewCell ,
        didShare event: EventItemViewModel
    )
}

final class EventMultipleCollectionViewCell: UICollectionViewCell, Reusable {
    static let minimumItemCount = 1

    enum Appearance {
        static let itemInset = LayoutInsets(left: 15, right: 15)
        static let eventItemWidth: CGFloat = 235
        static let eventItemHeight: CGFloat = 200
        static let videoEventItemHeight: CGFloat = 300
        static let itemRightSpacing: CGFloat = 15
    }

    weak var delegate: EventMultipleCollectionViewCellDelegate?

    private lazy var itemView = EventMultipleItemView()

    var items: [EventItemViewModel] = [] {
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
            make.height.equalTo(Appearance.eventItemHeight)
            make.bottom.lessThanOrEqualToSuperview()
        }
    }
}

extension EventMultipleCollectionViewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let isVideo = self.items[safe: indexPath.row]?.videoInfo != nil
        let height = isVideo ? Appearance.videoEventItemHeight : Appearance.eventItemHeight

        self.itemView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }

        if self.items.count == EventMultipleCollectionViewCell.minimumItemCount {
            let subtractedWidth = Appearance.itemInset.left + Appearance.itemInset.right
            let width = UIScreen.main.bounds.width - subtractedWidth
            return CGSize(width: width, height: height)
        }

        return isVideo
            ? CGSize(
                    width: collectionView.bounds.width
                        - Appearance.itemInset.left
                        - Appearance.itemRightSpacing,
                    height: height
                )
            : CGSize(width: Appearance.eventItemWidth, height: height)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let event = self.items[safe: indexPath.row] {
            self.delegate?.eventMultipleCollectionViewCell(self, didSelect: event)
        }
    }
}

extension EventMultipleCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let isVideo = self.items[safe: indexPath.row]?.videoInfo != nil
        if isVideo {
            let cell: VideoEventCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            self.items[safe: indexPath.row].flatMap { cell.configure(with: $0) }
            cell.delegate = self
            return cell
        }

        let cell: EventCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        self.items[safe: indexPath.row].flatMap { cell.configure(with: $0) }

        return cell
    }
}

extension EventMultipleCollectionViewCell: EventCollectionViewCellDelegate {
    func favoritesTableViewCell(
        _ cell: EventCollectionViewCell,
        didFavorite event: EventItemViewModel
    ) {
        self.delegate?.eventMultipleCollectionViewCell(self, didFavorite: event)
    }
}

extension EventMultipleCollectionViewCell: VideoEventCollectionViewCellDelegate {
    func videoEventCollectionViewCell(_ cell: VideoEventCollectionViewCell, didShare event: EventItemViewModel) {
        self.delegate?.eventMultipleCollectionViewCell(self, didShare: event)
    }
}
