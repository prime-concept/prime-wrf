import DeviceKit
import UIKit

protocol SearchRestaurantViewControllerProtocol: AnyObject {
    func set(restaurants: [SearchRestaurantViewModel])
    func set(restaurant: SearchRestaurantViewModel)
    func set(state: SearchRestaurantView.State)
    func set(restaurantsCount: Int)
    func set(tags: [SearchEventTagViewModel])

    func append(restaurants: [SearchRestaurantViewModel])

    func present(restaurant: Restaurant)
}

final class SearchRestaurantViewController: UIViewController, ScrollTrackable {
    let presenter: SearchRestaurantPresenterProtocol
    private lazy var searchRestaurantView = self.view as? SearchRestaurantView

    weak var delegate: SearchViewControllerDelegate?

    private var tags: [SearchEventTagViewModel] = []
    private var restaurants: [SearchRestaurantViewModel] = []

    private lazy var restaurantPresentationManager = FloatingControllerPresentationManager(
        context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
        groupID: SearchViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    var scrollView: UIScrollView? {
        return self.searchRestaurantView?.restaurantsTableView
    }

    init(presenter: SearchRestaurantPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = SearchRestaurantView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadRestaurants()
    }
}

extension SearchRestaurantViewController: SearchRestaurantViewControllerProtocol {
    func set(restaurants: [SearchRestaurantViewModel]) {
        self.restaurants = restaurants
        self.searchRestaurantView?.updateTableView(delegate: self, dataSource: self)
    }

    func set(restaurant: SearchRestaurantViewModel) {
        let indexPath = IndexPath(row: restaurant.id, section: 0)
        self.restaurants[indexPath.row] = restaurant
        self.searchRestaurantView?.restaurantsTableView.reloadRows(at: [indexPath], with: .none)
    }

    func set(tags: [SearchEventTagViewModel]) {
        self.tags = tags
        searchRestaurantView?.setupTagsCollectionView(hidden: tags.isEmpty)
        searchRestaurantView?.updateCategoriesCollectionView(delegate: self, dataSource: self)
    }

    func set(state: SearchRestaurantView.State) {
        self.searchRestaurantView?.state = state
    }

    func set(restaurantsCount: Int) {
        self.delegate?.updateRestaurantsCount(count: restaurantsCount)
    }

    func append(restaurants: [SearchRestaurantViewModel]) {
        var lastRow = self.restaurants.count - 1
        let indexes: [IndexPath] = restaurants.map { _ in
            lastRow += 1
            return IndexPath(row: lastRow, section: 0)
        }
        self.restaurants.append(contentsOf: restaurants)
        self.searchRestaurantView?.restaurantsTableView.insertRows(at: indexes, with: .none)
    }

    func present(restaurant: Restaurant) {
        let restaurantController = RestaurantAssembly(restaurant: restaurant).makeModule()
        self.restaurantPresentationManager.contentViewController = restaurantController
        self.restaurantPresentationManager.present()

        // TODO: extract scrollView getter through assembly
        if let restaurantViewController = restaurantController as? RestaurantViewController,
           let trackedScrollView = restaurantViewController.restaurantView?.scrollView {
            self.restaurantPresentationManager.track(scrollView: trackedScrollView)
        }
    }
}

extension SearchRestaurantViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.searchRestaurantView?.appearance.itemHeight ?? 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = self.restaurants[safe: indexPath.row] {
            self.presenter.select(restaurant: model.id)
        }
    }

    public func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard (self.restaurants.count - 1) == indexPath.row else {
            return
        }
        self.presenter.loadNextRestaurants()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.childDidScroll()
    }
}

extension SearchRestaurantViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchRestaurantTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let model = self.restaurants[safe: indexPath.row] {
            cell.configure(with: model, isSmall: Device.current.diagonal <= 4.0)
        }
        return cell
    }
}

extension SearchRestaurantViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == searchRestaurantView?.tagsCollectionView {
            let height = searchRestaurantView?.appearance.categoryItemHeight ?? 0
            let text = tags[indexPath.row].title
            let font = UIFont.wrfFont(ofSize: 14)
            let constraintRect = CGSize(
                width: .greatestFiniteMagnitude,
                height: height
            )
            let boundingBox = text.boundingRect(
                with: constraintRect,
                options: [
                    .usesLineFragmentOrigin,
                    .usesFontLeading
                ],
                attributes: [NSAttributedString.Key.font: font],
                context: nil
            )
            let titleLabelInsets = (collectionView.cellForItem(at: indexPath) as? SearchEventTagCollectionViewCell)?
                .itemView
                .appearance
                .titleLabelInsets ?? LayoutInsets(left: 25.0, right: 25.0)

            let width = boundingBox.size.width + titleLabelInsets.left + titleLabelInsets.right

            return CGSize(width: width, height: height)
        }
        return CGSize(
            width: UIScreen.main.bounds.width,
            height: searchRestaurantView?.appearance.itemHeight ?? 1
        )
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let tag = tags[safe: indexPath.row] else { return }
        presenter.select(tag: tag.id)
    }
}

extension SearchRestaurantViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tags.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let tag = tags[indexPath.row]
        let cell: SearchEventTagCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: tag)
        return cell
    }
}
