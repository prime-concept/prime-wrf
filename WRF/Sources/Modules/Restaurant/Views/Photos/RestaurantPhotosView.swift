import SnapKit
import UIKit

extension RestaurantPhotosView {
    struct Appearance {
        let insets = LayoutInsets(top: 20, bottom: 0)

        let titleFont = UIFont.wrfFont(ofSize: 11, weight: .medium)
        var titleTextColor = Palette.shared.textSecondary
        let titleEditorLineHeight: CGFloat = 13
        let titleInsets = LayoutInsets(left: 15, bottom: 8)

        let collectionViewContentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let collectionViewItemSize = CGSize(width: 95, height: 60)
        let collectionViewItemSpacing: CGFloat = 5
    }
}

final class RestaurantPhotosView: UIView {
    let appearance: Appearance

    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = self.appearance.collectionViewItemSize
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = self.appearance.collectionViewItemSpacing
        return layout
    }()

    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = self.appearance.collectionViewContentInset
        collectionView.register(cellClass: RestaurantPhotoCollectionViewCell.self)
        return collectionView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Фото".uppercased(),
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        label.textColorThemed = self.appearance.titleTextColor
        return label
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.titleLabel.intrinsicContentSize.height
                + self.appearance.titleInsets.bottom
                + self.appearance.collectionViewItemSize.height
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
    }

    // MARK: - Public API

    func updateCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.collectionView.delegate = delegate
        self.collectionView.dataSource = dataSource
        self.collectionView.reloadData()
    }
}

extension RestaurantPhotosView: ProgrammaticallyDesignable {
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
