import SafariServices
import UIKit

protocol FavoritesViewControllerProtocol: UIViewController {
    func set(events: [[FavoritesEventViewModel]])
    func set(index: Int, event: [FavoritesEventViewModel])
    func append(events: [[FavoritesEventViewModel]])
    func append(event: [FavoritesEventViewModel])
    func remove(event index: Int)

    func set(restaurants: [FavoritesRestaurantViewModel])
    func set(index: Int, restaurant: FavoritesRestaurantViewModel)
    func append(restaurants: [FavoritesRestaurantViewModel])
    func append(restaurant: FavoritesRestaurantViewModel)
    func remove(restaurant index: Int)

    func show(restaurant: Restaurant, assessment: PrimePassAssessment?)
    func show(event: Event)
}

protocol FavoritesModuleOutput: AnyObject {
    func updateFavoritesCount(count: Int)
}

final class FavoritesViewController: UIViewController {
    let presenter: FavoritesPresenterProtocol
    lazy var favoritesView = self.view as? FavoritesView

    var events: [[FavoritesEventViewModel]] = []
    var restaurants: [FavoritesRestaurantViewModel] = []

    private weak var moduleOutput: FavoritesModuleOutput?

    private lazy var eventPresentationManager = FloatingControllerPresentationManager(
        context: .event,
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private lazy var eventWebPresentationManager = FloatingControllerPresentationManager(
        context: .eventWeb,
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: .light
    )

    private lazy var restaurantPresentationManager = FloatingControllerPresentationManager(
        context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
        groupID: RestaurantViewController.floatingControllerGroupID,
        sourceViewController: self
    )

    private var eventsDataSource: FavoritesEventDataSource? {
        didSet {
            guard let dataSource = self.eventsDataSource else {
                return
            }
            self.favoritesView?.updateFavoritesCollectionView(delegate: self, dataSource: dataSource)
        }
    }

    private var restaurantsDataSource: FavoritesRestaurantDataSource? {
        didSet {
            guard let dataSource = self.restaurantsDataSource else {
                return
            }
            self.favoritesView?.updateFavoritesCollectionView(delegate: self, dataSource: dataSource)
        }
    }

    init(presenter: FavoritesPresenterProtocol, moduleOutput: FavoritesModuleOutput? = nil) {
        self.presenter = presenter
        self.moduleOutput = moduleOutput
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
		var appearance = FavoritesView.Appearance()
		
		if PGCMain.shared.featureFlags.profile.shouldDisplayEventCarousel {
            appearance.backgroundColor = Palette.shared.backgroundColor0
		}

        let view = FavoritesView(frame: UIScreen.main.bounds, appearance: appearance)
        view.delegate = self
        self.view = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoritesView?.updateFavoritesCollectionView(
            delegate: self,
            dataSource: FavoritesRestaurantDataSource(self, delegate: self)
        )

        self.presenter.loadFavorites()
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    func set(events: [[FavoritesEventViewModel]]) {
        self.events = events

        self.moduleOutput?.updateFavoritesCount(count: events.count)
        self.favoritesView?.isEmptyData = events.isEmpty
        if !events.isEmpty {
            self.favoritesView?.isRestaurantsSelected = false
        }
        self.eventsDataSource = FavoritesEventDataSource(self, delegate: self)
    }

    func set(index: Int, event: [FavoritesEventViewModel]) {
        let indexPath = IndexPath(row: index, section: 0)
        self.events[index] = event
        self.favoritesView?.favoritesCollectionView.reloadItems(at: [indexPath])
    }

    func append(events: [[FavoritesEventViewModel]]) {
        var lastRow = self.events.count - 1
        let indexes: [IndexPath] = events.map { _ in
            lastRow += 1
            return IndexPath(row: lastRow, section: 0)
        }

        self.events.append(contentsOf: events)
        self.moduleOutput?.updateFavoritesCount(count: self.events.count)
        self.favoritesView?.favoritesCollectionView.insertItems(at: indexes)
    }

    func append(event: [FavoritesEventViewModel]) {
        defer {
            self.moduleOutput?.updateFavoritesCount(count: self.events.count)
        }

        if self.events.isEmpty {
            self.events.append(event)
            self.favoritesView?.isEmptyData = events.isEmpty
            self.favoritesView?.favoritesCollectionView.reloadData()
            return
        }

        let indexPath = IndexPath(row: 0, section: 0)
        self.events.insert(event, at: indexPath.row)
        self.favoritesView?.favoritesCollectionView.insertItems(at: [indexPath])
    }

    func remove(event index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.events.remove(at: indexPath.row)
        self.favoritesView?.favoritesCollectionView.deleteItems(at: [indexPath])
    }

    func set(restaurants: [FavoritesRestaurantViewModel]) {
        self.restaurants = restaurants

        self.moduleOutput?.updateFavoritesCount(count: restaurants.count)
        self.favoritesView?.isEmptyData = restaurants.isEmpty
        if !restaurants.isEmpty {
            self.favoritesView?.isRestaurantsSelected = true
        }
        self.restaurantsDataSource = FavoritesRestaurantDataSource(self, delegate: self)
    }

    func set(index: Int, restaurant: FavoritesRestaurantViewModel) {
        let indexPath = IndexPath(row: index, section: 0)
        self.restaurants[indexPath.row] = restaurant
        self.favoritesView?.favoritesCollectionView.reloadItems(at: [indexPath])
    }

    func append(restaurants: [FavoritesRestaurantViewModel]) {
        var lastRow = self.restaurants.count - 1
        let indexes: [IndexPath] = restaurants.map { _ in
            lastRow += 1
            return IndexPath(row: lastRow, section: 0)
        }
        self.restaurants.append(contentsOf: restaurants)
        self.moduleOutput?.updateFavoritesCount(count: self.restaurants.count)
        self.favoritesView?.favoritesCollectionView.insertItems(at: indexes)
    }

    func append(restaurant: FavoritesRestaurantViewModel) {
        defer {
            self.moduleOutput?.updateFavoritesCount(count: self.events.count)
        }

        if self.restaurants.isEmpty {
            self.restaurants.append(restaurant)
            self.favoritesView?.isEmptyData = events.isEmpty
            self.favoritesView?.favoritesCollectionView.reloadData()
            return
        }

        let indexPath = IndexPath(row: 0, section: 0)
        self.restaurants.insert(restaurant, at: indexPath.row)
        self.favoritesView?.favoritesCollectionView.insertItems(at: [indexPath])
    }

    func remove(restaurant index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        self.restaurants.remove(at: indexPath.row)
        self.favoritesView?.favoritesCollectionView.deleteItems(at: [indexPath])
    }

    func show(restaurant: Restaurant, assessment: PrimePassAssessment?) {
        let restaurantController = RestaurantAssembly(restaurant: restaurant, assessment: assessment).makeModule()
        self.restaurantPresentationManager.contentViewController = restaurantController
        self.restaurantPresentationManager.present()

        // TODO: extract scrollView getter through assembly
        if let restaurantViewController = restaurantController as? RestaurantViewController,
           let trackedScrollView = restaurantViewController.restaurantView?.scrollView {
            restaurantViewController.restaurantControllerPresentator = RestaurantControllerPresentator(
                manager: self.restaurantPresentationManager
            )
            self.restaurantPresentationManager.track(scrollView: trackedScrollView)
        }
    }

    func show(event: Event) {
        if let url = URL(string: event.partnerLink ?? "") {
            self.eventWebPresentationManager.contentViewController = SFSafariViewController(url: url)
            self.eventWebPresentationManager.present()
        } else {
            let assembly = EventAssembly(event: event)

            self.eventPresentationManager.contentViewController = assembly.makeModule()
            self.eventPresentationManager.present()

            if let trackedScrollView = assembly.trackedScrollView {
                self.eventPresentationManager.track(scrollView: trackedScrollView)
            }
        }
    }
}

extension FavoritesViewController: FavoritesViewDelegate {
    func favoritesViewDidRequestEventsLoad() {
        self.events = []
        self.eventsDataSource = FavoritesEventDataSource(self, delegate: self)
        self.favoritesView?.isLoading = true

        self.presenter.loadFavorites(type: .events)
    }

    func favoritesViewDidRequestRestaurantsLoad() {
        self.restaurants = []
        self.restaurantsDataSource = FavoritesRestaurantDataSource(self, delegate: self)
        self.favoritesView?.isLoading = true

        self.presenter.loadFavorites(type: .restaurants)
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.dataSource is FavoritesRestaurantDataSource {
            if let item = self.restaurants[safe: indexPath.row] {
                self.presenter.select(restaurant: item.id)
            }
        }
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: UIScreen.main.bounds.width,
            height: self.favoritesView?.appearance.itemHeight ?? 1
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        switch collectionView.dataSource {
        case is FavoritesRestaurantDataSource:
            guard (self.restaurants.count - 1) == indexPath.row else {
                return
            }
            self.presenter.loadNextRestaurants()
        case is FavoritesEventDataSource:
            guard (self.events.count - 1) == indexPath.row else {
                return
            }
            self.presenter.loadNextEvents()
        default:
            break
        }
    }
}

extension FavoritesViewController: FavoritesCollectionViewCellDelegate {
    func favoritesTableViewCell(
        _ cell: FavoritesCollectionViewCell,
        didFavorite model: FavoritesRestaurantViewModel
    ) {
        self.presenter.update(restaurant: model)
    }
}

extension FavoritesViewController: FavoritesMultiEventCollectionViewCellDelegate {
    func eventMultipleCollectionViewCell(
        _ cell: FavoritesMultiEventCollectionViewCell,
        didFavorite model: FavoritesEventViewModel
    ) {
        self.presenter.update(event: model)
    }

    func eventMultipleItemSelected(
        _ cell: FavoritesMultiEventCollectionViewCell,
        didSelect model: FavoritesEventViewModel
    ) {
        self.presenter.select(event: model.id)
    }
}

private class FavoritesEventDataSource: NSObject, UICollectionViewDataSource {
    private weak var controller: FavoritesViewController?
    private weak var delegate: FavoritesMultiEventCollectionViewCellDelegate?

    init(_ controller: FavoritesViewController?, delegate: FavoritesMultiEventCollectionViewCellDelegate?) {
        self.controller = controller
        self.delegate = delegate
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.controller?.events.count ?? 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: FavoritesMultiEventCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self.delegate
        if let events = self.controller?.events[safe: indexPath.row] {
            cell.items = events
        }
        return cell
    }
}

private class FavoritesRestaurantDataSource: NSObject, UICollectionViewDataSource {
    private weak var controller: FavoritesViewController?
    private weak var delegate: FavoritesCollectionViewCellDelegate?

    init(_ controller: FavoritesViewController?, delegate: FavoritesCollectionViewCellDelegate?) {
        self.controller = controller
        self.delegate = delegate
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.controller?.restaurants.count ?? 0
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: FavoritesCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self.delegate
        if let restaurant = self.controller?.restaurants[safe: indexPath.row] {
            cell.configure(with: restaurant)
        }
        return cell
    }
}
