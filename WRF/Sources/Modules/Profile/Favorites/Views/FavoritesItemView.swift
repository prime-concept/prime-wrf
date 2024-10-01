import UIKit

extension FavoritesItemView {
    struct Appearance {
        let headerViewCornerRadius: CGFloat = 15
        let headerImageInsets = LayoutInsets(top: 5, right: 5)
    }
}

final class FavoritesItemView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.headerView.title = self.title
        }
    }

    var address: String? {
        didSet {
            self.headerView.address = self.address
        }
    }

    var distance: String? {
        didSet {
            self.headerView.distance = self.distance
        }
    }

    var price: String? {
        didSet {
            self.headerView.price = self.price
        }
    }

    var rating: Int = 0 {
        didSet {
            self.headerView.rating = self.rating
        }
    }

    var ratingText: String? {
        didSet {
            self.headerView.ratingText = self.ratingText
        }
    }

    var imageURL: URL? {
        didSet {
            self.headerView.imageURL = self.imageURL
        }
    }

    var logoURL: URL? {
        didSet {
            self.headerView.logoURL = self.logoURL
        }
    }

    var isFavorite: Bool = false {
        didSet {
            self.favoriteControl.isSelected = self.isFavorite
        }
    }

    private lazy var headerView = RestaurantHeaderView()
    private(set) lazy var favoriteControl = FavoriteControl()

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

    // MARK: - Public API

    func clear() {
        self.headerView.clear()
        self.favoriteControl.isSelected = false
    }
}

extension FavoritesItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.headerView.clipsToBounds = true
        self.headerView.layer.cornerRadius = self.appearance.headerViewCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.headerView.addSubview(self.favoriteControl)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.favoriteControl.translatesAutoresizingMaskIntoConstraints = false
        self.favoriteControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.headerImageInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.headerImageInsets.right)
        }
    }
}
