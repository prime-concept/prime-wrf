import SnapKit
import UIKit

extension SearchEventView {
    struct Appearance {
        let categoryItemHeight: CGFloat = 36
        let categorySpacing: CGFloat = 10
        let categoryCollectionViewTopOffset: CGFloat = 130
        let categoryCollectionViewInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        let emptyViewOffset: CGFloat = 166

        let itemHeight: CGFloat = PGCMain.shared.featureFlags.searching.useEventItemSmallImageView ? 165 : 210
        let eventCollectionViewTopOffset: CGFloat = 11

        let backgroundColor = Palette.shared.backgroundColor0

        let emptyTopViewTextColor = Palette.shared.textSecondary
        let emptyViewTopOffset: CGFloat = 20.0
    }
}

final class SearchEventView: UIView {
    let appearance: Appearance

    enum State {
        case querySearchIsEmpty
        case data(hasData: Bool)
    }

    var state: State = .data(hasData: false) {
        didSet {
            switch self.state {
            case .data(let hasData):
                if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
                    emptyTopView.isHidden = true
                } else {
                    emptyCenterView.state = .noData
                    emptyCenterView.title = "Данных нет"
                    eventsCollectionView.backgroundView?.isHidden = hasData
                }
            case .querySearchIsEmpty:
                if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
                    emptyTopView.isHidden = false
                } else {
                    emptyCenterView.state = .noData
                    emptyCenterView.title = "По вашему запросу ничего\nне найдено"
                    eventsCollectionView.backgroundView?.isHidden = false
                }
            }
        }
    }

    private lazy var tagCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = self.appearance.categorySpacing
        layout.minimumLineSpacing = 0
        return layout
    }()

    private(set) lazy var tagsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.tagCollectionFlowLayout
        )
        collectionView.contentInset = self.appearance.categoryCollectionViewInsets
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellClass: SearchEventTagCollectionViewCell.self)
        return collectionView
    }()

    private lazy var eventsCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()

    private(set) lazy var eventsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.eventsCollectionFlowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellClass: SearchEventMultiCollectionViewCell.self)
        return collectionView
    }()

    private lazy var emptyCenterView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "По вашему запросу ничего\nне найдено"
        view.image = #imageLiteral(resourceName: "search")
        return view
    }()

    private lazy var emptyTopView: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColorThemed = appearance.emptyTopViewTextColor
        label.text = """
        Хм, мы ничего не нашли.
        Попробуйте изменить параметры поиска
        """
        return label
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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
        if !PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
            eventsCollectionView.backgroundView = emptyCenterView
        }
    }

    // MARK: - Public API

    func updateEventsCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.eventsCollectionView.delegate = delegate
        self.eventsCollectionView.dataSource = dataSource
        self.eventsCollectionView.reloadData()
    }

    func updateCategoriesCollectionView(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource
    ) {
        self.tagsCollectionView.delegate = delegate
        self.tagsCollectionView.dataSource = dataSource
        self.tagsCollectionView.reloadData()
    }

    func setupTagsCollectionView(hidden: Bool) {
        tagsCollectionView.snp.updateConstraints { make in
            make.height.equalTo(hidden ? 0 : appearance.categoryItemHeight)
        }
    }
}

extension SearchEventView: ProgrammaticallyDesignable {
    func setupView() {
        backgroundColorThemed = appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tagsCollectionView)
        self.addSubview(self.eventsCollectionView)
        if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
            addSubview(emptyTopView)
        }
    }

    func makeConstraints() {
        self.tagsCollectionView.snp.makeConstraints { make in
            make.top
                .equalTo(self.safeAreaLayoutGuide.snp.top)
                .offset(self.appearance.categoryCollectionViewTopOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.categoryItemHeight)
        }

        self.eventsCollectionView.snp.makeConstraints { make in
            make.top
                .equalTo(self.tagsCollectionView.snp.bottom)
                .offset(self.appearance.eventCollectionViewTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
        if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
            emptyTopView.snp.makeConstraints { make in
                make.top.equalTo(tagsCollectionView.snp.bottom).offset(appearance.emptyViewTopOffset)
                make.leading.trailing.equalToSuperview()
            }
        }
    }
}
