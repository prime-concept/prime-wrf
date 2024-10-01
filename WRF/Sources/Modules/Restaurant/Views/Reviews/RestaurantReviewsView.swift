import SnapKit
import UIKit

extension RestaurantReviewsView {
    struct Appearance {
        var insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

        let rateFont = UIFont.wrfFont(ofSize: 25, weight: .light)
        var rateTextColor = Palette.shared.textSecondary
        let rateEditorLineHeight: CGFloat = 29
        let rateInsets = LayoutInsets(left: 15, bottom: 10)

        let countFont = UIFont.wrfFont(ofSize: 11)
        var countTextColor = Palette.shared.textSecondary
        var countHightlightTextColor = Palette.shared.textPrimary
        let countEditorLineHeight: CGFloat = 13
        let countInsets = LayoutInsets(top: 3, left: 10, right: 16)

        let collectionViewContentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let collectionViewItemHeight: CGFloat = 125
        let collectionViewItemOverlap: CGFloat = 10
        let collectionViewItemSpacing: CGFloat = 10

        let starsSpacing: CGFloat = 10
        let starsSize = CGSize(width: 20, height: 20)
        let starsInsets = LayoutInsets(left: 15)
        var starFilledColor = Palette.shared.iconsBrand
        var starColor = Palette.shared.iconsSecondary
    }
}

final class RestaurantReviewsView: UIView {
    let appearance: Appearance

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = RestaurantReviewsFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = self.appearance.collectionViewItemSpacing
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = self.appearance.collectionViewContentInset
        collectionView.register(cellClass: RestaurantReviewCollectionViewCell.self)
        collectionView.decelerationRate = .fast
        collectionView.tag = 1 // Marked for detecting collection scrolling in delegate method
        return collectionView
    }()

    private lazy var ratingView: StarsRatingView = {
        var appearance = StarsRatingView.Appearance()
        appearance.starClearColor = self.appearance.starColor
        appearance.starFilledColor = self.appearance.starFilledColor
        appearance.starsSize = self.appearance.starsSize
        appearance.starsSpacing = self.appearance.starsSpacing
        appearance.starsImage = #imageLiteral(resourceName: "restaurant-item-star-rating")
        let view = StarsRatingView(appearance: appearance)
        return view
    }()

    private lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.rateFont
        label.textColorThemed = self.appearance.rateTextColor
        return label
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.countFont
        label.textColorThemed = self.appearance.countTextColor
        return label
    }()

    var rate: Float? {
        didSet {
            if let rate = self.rate {
                let rateText = FormatterHelper.floatRepresentation(rate, precision: 1)
                let text = LineHeightStringMaker.makeString(
                    "\(rateText) из 5",
                    editorLineHeight: self.appearance.countEditorLineHeight,
                    font: self.appearance.countFont
                )

                let range = NSRange(location: 0, length: rateText.count)
                text.addAttribute(.foregroundColor, value: self.appearance.countHightlightTextColor, range: range)
                self.rateLabel.attributedText = text
                self.ratingView.starsCount = Int(rate)
            }
            self.rateLabel.isHidden = self.rate == nil
        }
    }

    var totalCount: Int? {
        didSet {
            if let count = self.totalCount {
                self.countLabel.attributedText = LineHeightStringMaker.makeString(
                    FormatterHelper.assessments(count),
                    editorLineHeight: self.appearance.countEditorLineHeight,
                    font: self.appearance.countFont
                )
            }
            self.countLabel.isHidden = self.totalCount == nil
        }
    }

    override var intrinsicContentSize: CGSize {
        let isCollectionEmpty = self.collectionView.numberOfSections == 0
            || (self.collectionView.numberOfSections == 1 && self.collectionView.numberOfItems(inSection: 0) == 0)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.rateLabel.intrinsicContentSize.height
                + (isCollectionEmpty ? 0 : self.appearance.rateInsets.bottom)
                + (isCollectionEmpty ? 0 : self.appearance.collectionViewItemHeight)
                + self.appearance.insets.bottom
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
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

extension RestaurantReviewsView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.ratingView)
        self.addSubview(self.rateLabel)
        self.addSubview(self.countLabel)
        self.addSubview(self.collectionView)
    }

    func makeConstraints() {
        self.rateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
        }

        self.countLabel.translatesAutoresizingMaskIntoConstraints = false
        self.countLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.rateLabel.snp.trailing).offset(self.appearance.countInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.countInsets.right)
            make.centerY.equalTo(self.rateLabel.snp.centerY).offset(self.appearance.countInsets.top)
        }

        self.ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.ratingView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.rateInsets.left)
            make.centerY.equalTo(self.rateLabel.snp.centerY)
            make.trailing.lessThanOrEqualTo(self.rateLabel.snp.leading).offset(-self.appearance.rateInsets.left)
        }

        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.rateLabel.snp.bottom).offset(self.appearance.rateInsets.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}

private class RestaurantReviewsFlowLayout: UICollectionViewFlowLayout {
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

        let itemSpace = self.itemSize.width
            + self.minimumInteritemSpacing
            + RestaurantReviewsView.Appearance().collectionViewItemOverlap
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
