import SnapKit
import UIKit

protocol FavoritesViewDelegate: AnyObject {
    func favoritesViewDidRequestEventsLoad()
    func favoritesViewDidRequestRestaurantsLoad()
}

extension FavoritesView {
    struct Appearance {
		var itemHeight: CGFloat = PGCMain.shared.featureFlags.favorites.favoritesViewHeight

        let categoryViewInsets = LayoutInsets(top: 12, left: 15, right: 15)
        let categoryViewHeight: CGFloat = 36

        let favoritesTopOffset: CGFloat = 15
        var backgroundColor = Palette.shared.clear
    }
}

final class FavoritesView: UIView {
    let appearance: Appearance

    weak var delegate: FavoritesViewDelegate?

    var isLoading: Bool = true {
        didSet {
            self.emptyView.state = .loading
            self.favoritesCollectionView.backgroundView?.isHidden = false
        }
    }

    var isEmptyData: Bool = false {
        didSet {
            self.emptyView.state = .noData
            self.favoritesCollectionView.backgroundView?.isHidden = !self.isEmptyData
        }
    }

    var isRestaurantsSelected: Bool = true {
        didSet {
            self.categoriesView.eventsTagView.isSelected = !isRestaurantsSelected
            self.categoriesView.restaurantsTagView.isSelected = isRestaurantsSelected
        }
    }

    private lazy var emptyView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "Вы ещё не добавляли ничего\nв избранное"
        view.image = UIImage(named: "favorite")
        return view
    }()

    private lazy var categoriesView: FavoritesTypesView = {
        let view = FavoritesTypesView()
        let restaurantTap = UITapGestureRecognizer(target: self, action: #selector(self.restaurantClick))
        view.restaurantsTagView.addGestureRecognizer(restaurantTap)
        let eventTap = UITapGestureRecognizer(target: self, action: #selector(self.eventClick))
        view.eventsTagView.addGestureRecognizer(eventTap)
        return view
    }()

    private lazy var favoritesCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        return layout
    }()

    private(set) lazy var favoritesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.favoritesCollectionFlowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(cellClass: FavoritesCollectionViewCell.self)
        collectionView.register(cellClass: FavoritesMultiEventCollectionViewCell.self)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.favoritesCollectionView.backgroundView = self.emptyView
    }

    func updateFavoritesCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.favoritesCollectionView.delegate = delegate
        self.favoritesCollectionView.dataSource = dataSource
        self.favoritesCollectionView.reloadData()
    }

    // MARK: - Private API

    @objc
    private func eventClick() {
        self.categoriesView.eventsTagView.isSelected = true
        self.categoriesView.restaurantsTagView.isSelected = false

        self.delegate?.favoritesViewDidRequestEventsLoad()
    }

    @objc
    private func restaurantClick() {
        self.categoriesView.eventsTagView.isSelected = false
        self.categoriesView.restaurantsTagView.isSelected = true

        self.delegate?.favoritesViewDidRequestRestaurantsLoad()
    }
}

extension FavoritesView: ProgrammaticallyDesignable {
    public func setupView() {
        self.categoriesView.restaurantsTagView.isSelected = true
        self.categoriesView.eventsTagView.isSelected = false
		self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.categoriesView)
        self.addSubview(self.favoritesCollectionView)
    }

    func makeConstraints() {
        self.categoriesView.translatesAutoresizingMaskIntoConstraints = false
        self.categoriesView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.categoryViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.categoryViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.categoryViewInsets.right)
            make.height.equalTo(self.appearance.categoryViewHeight)
        }

        self.favoritesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.favoritesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.categoriesView.snp.bottom).offset(self.appearance.favoritesTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
