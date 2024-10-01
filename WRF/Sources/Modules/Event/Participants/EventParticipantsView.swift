import SnapKit
import UIKit

extension EventParticipantsView {
    struct Appearance {
        var insets = LayoutInsets(top: 20, bottom: 0)

        let titleFont = UIFont.wrfFont(ofSize: 11, weight: .medium)
        let titleTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let titleEditorLineHeight: CGFloat = 13
        let titleInsets = LayoutInsets(left: 15, bottom: 10)
        
        let collectionViewContentInset = PGCMain.shared.featureFlags.map.showMapSearch
        ? UIEdgeInsets(top: 0, left: -16, bottom: 0, right: -16)
        : UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        let collectionViewItemHeight: CGFloat = 125
        let collectionViewItemSpacing: CGFloat = 5
        let collectionViewItemOverlap: CGFloat = 30

        let backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.2, alpha: 1.0)
    }
}

final class EventParticipantsView: UIView {
    let appearance: Appearance

    private lazy var flowLayout: EventParticipantsFlowLayout = {
        let layout = EventParticipantsFlowLayout()
        layout.scrollDirection = PGCMain.shared.featureFlags.map.showMapSearch ? .vertical : .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = self.appearance.collectionViewItemSpacing
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = PGCMain.shared.featureFlags.map.showMapSearch
            ? appearance.backgroundColor
            : .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = self.appearance.collectionViewContentInset
        collectionView.register(cellClass: EventParticipantCollectionViewCell.self)
        collectionView.decelerationRate = .fast
        return collectionView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Рестораны-участники".uppercased(),
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        label.textColor = self.appearance.titleTextColor
        return label
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.titleLabel.intrinsicContentSize.height
                + self.appearance.titleInsets.bottom
                + self.appearance.collectionViewItemHeight
                + self.appearance.insets.bottom
        )
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()

        self.flowLayout.itemSize = CGSize(
            width: self.bounds.width
                - self.appearance.collectionViewContentInset.left
                - self.appearance.collectionViewItemSpacing
                - self.appearance.collectionViewItemOverlap,
            height: self.appearance.collectionViewItemHeight
        )
        self.flowLayout.invalidateLayout()
    }

    // MARK: - Public API

    func updateCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = dataSource
        self.collectionView.reloadData()
    }
}

extension EventParticipantsView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
        }

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.titleInsets.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}

private class EventParticipantsFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        let parentOffset = super.targetContentOffset(
            forProposedContentOffset: proposedContentOffset,
            withScrollingVelocity: velocity
        )

        guard let collectionView = self.collectionView else {
            return parentOffset
        }

        let itemSpace = self.itemSize.width + self.minimumInteritemSpacing
        var currentItemIDx = round(collectionView.contentOffset.x / itemSpace)

        let velocityX = velocity.x
        if velocityX > 0 {
            currentItemIDx += 1
        } else if velocityX < 0 {
            currentItemIDx -= 1
        }

        let nearestPageOffset = currentItemIDx * itemSpace - collectionView.contentInset.left
        return CGPoint(x: nearestPageOffset, y: parentOffset.y)
    }
}
