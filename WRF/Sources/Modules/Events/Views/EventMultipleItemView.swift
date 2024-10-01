import SnapKit
import UIKit

extension EventMultipleItemView {
    struct Appearance {
        let itemSpacing: CGFloat = 10
        let eventCollectionViewInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
}

final class EventMultipleItemView: UIView {
    let appearance: Appearance

    private lazy var eventCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = self.appearance.itemSpacing
        layout.minimumLineSpacing = self.appearance.itemSpacing
        return layout
    }()

    private lazy var eventCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.eventCollectionFlowLayout
        )
        collectionView.contentInset = self.appearance.eventCollectionViewInsets
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellClass: EventCollectionViewCell.self)
        collectionView.register(cellClass: FavoritesEventCollectionViewCell.self)
        collectionView.register(cellClass: SearchEventCollectionViewCell.self)
        collectionView.register(cellClass: VideoEventCollectionViewCell.self)
        return collectionView
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public api

    func updateEventCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.eventCollectionView.delegate = delegate
        self.eventCollectionView.dataSource = dataSource
        self.eventCollectionView.reloadData()
    }
}

extension EventMultipleItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.eventCollectionView)
    }

    func makeConstraints() {
        self.eventCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.eventCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
