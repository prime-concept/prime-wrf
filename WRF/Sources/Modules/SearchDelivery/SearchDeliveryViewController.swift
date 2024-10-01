import DeviceKit
import UIKit

protocol SearchDeliveryViewControllerProtocol: AnyObject {
    func set(restaurants: [SearchDeliveryViewModel])
    func set(restaurant: SearchDeliveryViewModel)
    func set(state: SearchDeliveryView.State)
    func set(restaurantsCount: Int)

    func append(restaurants: [SearchDeliveryViewModel])

    func present(restaurant: Restaurant)
}

final class SearchDeliveryViewController: UIViewController, ScrollTrackable {
    let presenter: SearchDeliveryPresenterProtocol
    private lazy var searchDeliveryView = self.view as? SearchDeliveryView

    weak var delegate: SearchViewControllerDelegate?

    private var restaurants: [SearchDeliveryViewModel] = []

    private lazy var restaurantPresentationManager = FloatingControllerPresentationManager(
        context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
        groupID: SearchViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    var scrollView: UIScrollView? {
        return self.searchDeliveryView?.restaurantsTableView
    }

    init(presenter: SearchDeliveryPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = SearchDeliveryView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadRestaurants()
    }
}

extension SearchDeliveryViewController: SearchDeliveryViewControllerProtocol {
    func set(restaurants: [SearchDeliveryViewModel]) {
        self.restaurants = restaurants
        self.searchDeliveryView?.updateTableView(delegate: self, dataSource: self)
    }

    func set(restaurant: SearchDeliveryViewModel) {
        let indexPath = IndexPath(row: restaurant.id, section: 0)
        self.restaurants[indexPath.row] = restaurant
        self.searchDeliveryView?.restaurantsTableView.reloadRows(at: [indexPath], with: .none)
    }

    func set(state: SearchDeliveryView.State) {
        self.searchDeliveryView?.state = state
    }

    func set(restaurantsCount: Int) {
        self.delegate?.updateDeliveryCount(count: restaurantsCount)
    }

    func append(restaurants: [SearchDeliveryViewModel]) {
        var lastRow = self.restaurants.count - 1
        let indexes: [IndexPath] = restaurants.map { _ in
            lastRow += 1
            return IndexPath(row: lastRow, section: 0)
        }
        self.restaurants.append(contentsOf: restaurants)
        self.searchDeliveryView?.restaurantsTableView.insertRows(at: indexes, with: .none)
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

extension SearchDeliveryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.searchDeliveryView?.appearance.itemHeight ?? 1
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

extension SearchDeliveryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchDeliveryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let model = self.restaurants[safe: indexPath.row] {
            cell.configure(with: model, isSmall: Device.current.diagonal <= 4.0)
        }
        return cell
    }
}
