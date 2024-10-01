import SnapKit
import UIKit

extension SearchRestaurantView {
    struct Appearance {
        let itemHeight: CGFloat = 100
        let topViewOffset: CGFloat = 130
        let backgroundColor = Palette.shared.backgroundColor0

        let emptyTopViewTextColor = Palette.shared.textSecondary
        let emptyViewTopOffset: CGFloat = 20.0

        let categoryItemHeight: CGFloat = 36
        let categorySpacing: CGFloat = 10
        let categoryCollectionViewInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        let categoryCollectionViewTopOffset: CGFloat = 11
    }
}

final class SearchRestaurantView: UIView {
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
                    tagsCollectionView.isHidden = false
                } else {
                    self.emptyCenterView.state = .noData
                    self.emptyCenterView.title = "Данных нет"
                    self.restaurantsTableView.backgroundView?.isHidden = hasData
                }
            case .querySearchIsEmpty:
                if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
                    emptyTopView.isHidden = false
                    tagsCollectionView.isHidden = true
                } else {
                    self.emptyCenterView.state = .noData
                    self.emptyCenterView.title = "По вашему запросу ничего\nне найдено"
                    self.restaurantsTableView.backgroundView?.isHidden = false
                }
            }
        }
    }

    private lazy var emptyCenterView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "Данных нет"
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

    private lazy var topView = UIView()

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

    private(set) lazy var restaurantsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: SearchRestaurantTableViewCell.self)
        return tableView
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
            restaurantsTableView.backgroundView = emptyCenterView
        }

    }
    
    // MARK: - Public API
    
    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.restaurantsTableView.delegate = delegate
        self.restaurantsTableView.dataSource = dataSource
        self.restaurantsTableView.reloadData()
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

extension SearchRestaurantView: ProgrammaticallyDesignable {
    func setupView() {
        backgroundColorThemed = appearance.backgroundColor
    }
    
    func addSubviews() {
        addSubview(topView)
        addSubview(restaurantsTableView)
        if PGCMain.shared.featureFlags.searching.showTagsForRestaurants {
            addSubview(tagsCollectionView)
        }
        if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
            addSubview(emptyTopView)
        }
    }
    
    func makeConstraints() {
        topView.snp.makeConstraints { make in
            make.top
                .equalTo(safeAreaLayoutGuide.snp.top)
                .offset(appearance.topViewOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        if PGCMain.shared.featureFlags.searching.showTagsForRestaurants {
            tagsCollectionView.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(appearance.categoryItemHeight)
            }
        }
        restaurantsTableView.snp.makeConstraints { make in
            if PGCMain.shared.featureFlags.searching.showTagsForRestaurants {
                make.top.equalTo(tagsCollectionView.snp.bottom)
                    .offset(appearance.categoryCollectionViewTopOffset)
            } else {
                make.top.equalTo(topView.snp.bottom)
            }
            make.leading.trailing.bottom.equalToSuperview()
        }
        if PGCMain.shared.featureFlags.searching.showEmptyStateViewOnTop {
            emptyTopView.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(appearance.emptyViewTopOffset)
                make.leading.trailing.equalToSuperview()
            }
        }
    }
}
