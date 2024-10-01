import SnapKit
import UIKit

protocol HomeScreenViewDelegate: AnyObject {
    func homeScreenViewDidToggleFavorite(eventId: Event.IDType, favorite: Bool)
    func homeScreenViewDidSelectEvent(id: Event.IDType)
    func homeScreenViewOpenCitySelection(_ view: HomeScreenView)
    func homeScreenViewOpenSearch(_ view: HomeScreenView)
    func homeScreenViewOpenMap(_ view: HomeScreenView)
}

extension HomeScreenView {
    struct Appearance {
        let backgroundColor = Palette.shared.backgroundColor0
        var topOffset: CGFloat = 8
        let searchBarViewInsets = LayoutInsets(top: 8.0, left: 16.0, right: -16.0)
		let bannerHeight: CGFloat = 473
        let tagsViewHeight: CGFloat = 50
        let tagsCollectionViewInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        let tagsSpacing: CGFloat = 5
        let buttonSize = CGSize(width: 42, height: 36)
        let searchButtonInsets = LayoutInsets(left: 5, right: 15)
        let chatButtonInsets = LayoutInsets(top: 14, right: 15)
        let notificationButtonInsets = LayoutInsets(top: 14, right: 15)
        let locationButtonInsets = LayoutInsets(bottom: 10, right: 15)
        let filterButtonInsets = LayoutInsets(left: 15, right: 5)

        let restaurantsTableViewBackgroundColor = Palette.shared.clear

        let visaLogoSize = CGSize(width: 47, height: 15)
        let visaLogoRightInset: CGFloat = 15

        let searchBarViewHeight: CGFloat = 36.0
    }
}

final class HomeScreenView: UIView {
    let appearance: Appearance

    weak var delegate: HomeScreenViewDelegate?

    private lazy var restaurantsLoadingIndicator = WineLoaderView()

    // MARK: - subviews
    private(set) lazy var restaurantsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColorThemed = appearance.restaurantsTableViewBackgroundColor
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: BannerViewCell.self)
        tableView.register(cellClass: HomeScreenEventsCell.self)
        tableView.register(cellClass: MapRestaurantsTableViewCell.self)
        tableView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
        tableView.estimatedRowHeight = 104
        return tableView
    }()

    private lazy var searchBarView = HomeScreenSearchBarView()

    // MARK: - life cycle

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        backgroundColorThemed = appearance.backgroundColor

        addSubviews()
        makeConstraints()
        setupSearchBar()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        restaurantsTableView.delegate = delegate
        restaurantsTableView.dataSource = dataSource
        restaurantsTableView.reloadData()
    }

    // MARK: - setups

    func setupCityButton(with title: String) {
        searchBarView.setupCityButton(with: title)
    }

    private func setupSearchBar() {
        searchBarView.cityButtonTapAction = { [weak self] in
            guard let self, let delegate else { return }
            delegate.homeScreenViewOpenCitySelection(self)
        }
        searchBarView.setupSearchFieldTapAction(enabled: true)
        searchBarView.searchFieldTapAction = { [weak self] in
            guard let self, let delegate else { return }
            delegate.homeScreenViewOpenSearch(self)
        }
        searchBarView.currentLocationButtonTapAction = { [weak self] in
            guard let self, let delegate else { return }
            delegate.homeScreenViewOpenMap(self)
        }
    }

    // MARK: - actions

    func showLoading() {
        restaurantsLoadingIndicator.startAnimating()
    }

    func hideLoading() {
        restaurantsLoadingIndicator.stopAnimating()
    }
}

extension HomeScreenView: ProgrammaticallyDesignable {
    func addSubviews() {
        addSubview(searchBarView)
        addSubview(restaurantsTableView)
        addSubview(restaurantsLoadingIndicator)
        bringSubviewToFront(searchBarView)
    }
    
    func makeConstraints() {
        searchBarView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(appearance.searchBarViewInsets.top)
            make.leading.equalToSuperview().offset(appearance.searchBarViewInsets.left)
            make.trailing.equalToSuperview().offset(appearance.searchBarViewInsets.right)
            make.height.equalTo(appearance.searchBarViewHeight)
        }
        
        restaurantsTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        restaurantsLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
