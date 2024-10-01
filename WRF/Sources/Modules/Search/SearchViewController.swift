import Pageboy
import SnapKit
import Tabman
import UIKit

protocol SearchViewControllerProtocol: AnyObject {
    func search(events query: String)
    func search(events date: Date)
    func search(restaurants query: String)

    func set(search text: String)
    func set(calendar visible: Bool)

    func present(calendar date: Date)
}

protocol SearchViewControllerDelegate: AnyObject {
    func updateRestaurantsCount(count: Int)
    func updateEventsCount(count: Int)
    func updateDeliveryCount(count: Int)

    func childDidScroll()
}

protocol ScrollTrackable {
    var scrollView: UIScrollView? { get }
}

enum PageContext: Int {
    case restaurants
    case events
    case delivery
    
    var title: String {
        switch self {
        case .restaurants:
            "restaurants"
        case .events:
            "events"
        case .delivery:
            "delivery"
        }
    }
}

final class SearchViewController: TabmanViewController {
    static let floatingControllerGroupID = "search"

    enum Appearance {
        static let controllerHeight = (UIScreen.main.bounds.height / 3) * 2
        static let citiesCurtainHeight: CGFloat = UIScreen.main.bounds.height - 150
        static let citiesViewBackgroundColor = Palette.shared.backgroundColor0
    }

    private static let restaurantBarItemIndex = 0
    private static let eventsBarItemIndex = 1
    private static let deliveryBarItemIndex = 2

    let presenter: SearchPresenterProtocol
    private lazy var searchView = self.view as? SearchView

    var searchControllerPresentator: SearchControllerPresentator?

    private lazy var calendarPresentationManager: FloatingControllerPresentationManager = {
        let manager = FloatingControllerPresentationManager(
            context: .calendar,
            groupID: SearchViewController.floatingControllerGroupID,
            sourceViewController: self,
            grabberAppearance: .light
        )
        manager.contentInsetAdjustmentBehavior = .never
        return manager
    }()

    private var eventSearchInput: SearchEventChildModuleInput?
    private var restaurantSearchInput: SearchRestaurantChildModuleInput?
    private var deliverySearchInput: SearchDeliveryChildModuleInput?

    private var currentCity: SearchCityViewModel?
    private var defaultPage: PageContext = .restaurants

    private lazy var eventController: UIViewController = {
        let assembly = SearchEventAssembly()
        let controller = assembly.makeModule()

        // swiftlint:disable force_cast
        self.eventSearchInput = assembly.moduleInput as? SearchEventChildModuleInput
        let viewController = controller as! SearchEventViewController
        viewController.delegate = self
        return controller
    }()

    private lazy var restaurantController: UIViewController = {
        let assembly = SearchRestaurantAssembly()
        let controller = assembly.makeModule()

        // swiftlint:disable force_cast
        self.restaurantSearchInput = assembly.moduleInput as? SearchRestaurantChildModuleInput
        let viewController = controller as! SearchRestaurantViewController
        viewController.delegate = self
        return controller
    }()

	private lazy var deliveryController: UIViewController = {
        let assembly = SearchDeliveryAssembly()
        let controller = assembly.makeModule()

        // swiftlint:disable force_cast
        self.deliverySearchInput = assembly.moduleInput as? SearchDeliveryChildModuleInput
        let viewController = controller as! SearchDeliveryViewController
        viewController.delegate = self
        return controller
    }()

    private lazy var barItems: [WRFBarItem] = []

    private lazy var barDataSource = TabDataSource(
        items: self.barItems,
        offset: self.searchView?.appearance.tabContentTopOffset ?? 0
    )

    init(presenter: SearchPresenterProtocol, scrollTo page: PageContext) {
        self.defaultPage = page
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SearchView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        barItems = [
            WRFBarItem(title: "Рестораны", viewController: self.restaurantController),
            WRFBarItem(title: "События", viewController: self.eventController),
        ]

        if PGCMain.shared.featureFlags.searching.showDelivery {
            barItems.append(
                WRFBarItem(title: "Доставка", viewController: self.deliveryController)
            )
        }

        self.dataSource = self.barDataSource

        if let searchView = self.searchView {
            self.setupTabBar(searchView)
            searchView.headerView.searchBar.delegate = self
            searchView.headerView.setupSearchField(delegate: self)
            searchView.headerView.cityButtonTapAction = { [weak self] in
                let assembly = SearchCityAssembly()
                assembly.selectedCity = self?.currentCity

                guard
                    let searchCityViewController = assembly.makeModule() as? SearchCityViewController
                else {
                    return
                }

                searchCityViewController.view.snp.makeConstraints { make in
                    make.height.equalTo(Appearance.citiesCurtainHeight)
                }

                let curtain = CurtainViewController(
                    with: UIStackView.vertical(searchCityViewController.view),
                    backgroundColor: Palette.shared.clear,
                    curtainViewBackgroundColor: Appearance.citiesViewBackgroundColor
                )
                curtain.addChild(searchCityViewController)

                searchCityViewController.citySelectedCallback = { [weak self] city in
                    self?.currentCity = city
                    self?.searchView?.setupCityButton(with: city.title)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        curtain.dismiss(animated: true)
                    }
                }

                curtain.present(animated: false)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.track(at: self.defaultPage.rawValue)
    }

    // MARK: - Public API

    override func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageIndex,
        direction: NavigationDirection,
        animated: Bool
    ) {
        super.pageboyViewController(
            pageboyViewController,
            didScrollToPageAt: index,
            direction: direction,
            animated: animated
        )

        self.presenter.didTapOnSearchCategory(name: PageContext(rawValue: index)?.title ?? "")
        
        let context = index == SearchViewController.restaurantBarItemIndex
                ? PageContext.restaurants : PageContext.events
        self.presenter.pageScrolled(context: context)

        self.track(at: index)
    }

    // MARK: - Private API

    private func setupTabBar(_ view: SearchView) {
        let barLocation: BarLocation = .custom(
            view: view.tabContainerView,
            layout: { bar in
                bar.translatesAutoresizingMaskIntoConstraints = false
                bar.snp.makeConstraints { make in
                    make.top
                        .equalTo(view.headerView.snp.bottom)
                        .offset(self.searchView?.appearance.tabContainerTopOffset ?? 0)
                    make.leading.trailing.bottom.equalToSuperview()
                }
            }
        )
        self.addBar(view.makeTabBar(), dataSource: self.barDataSource, at: barLocation)
        self.scrollToPage(.at(index: self.defaultPage.rawValue), animated: false)
    }

    private func track(at index: Int) {
        let scrollView = (self.barItems[index].viewController as? ScrollTrackable)?.scrollView
        self.searchControllerPresentator?.track(scrollView: scrollView)
    }
}

extension SearchViewController: SearchViewControllerProtocol {
    func search(restaurants query: String) {
        self.restaurantSearchInput?.load(query: query)
    }

    func search(events query: String) {
        self.eventSearchInput?.load(query: query)
    }

    func search(events date: Date) {
        self.eventSearchInput?.load(events: date)
    }

    func set(search text: String) {
        searchView?.title = text
        searchView?.headerView.setupSearchField(text: text)
    }

    func set(calendar visible: Bool) {
        self.searchView?.showsCalendar = visible
    }

    func present(calendar date: Date) {
        let calendarController = RestaurantBookingCalendarAssembly(
            selectedDate: date
        ).makeModule()
        self.calendarPresentationManager.contentViewController = calendarController
        self.calendarPresentationManager.present()

        // TODO: extract scrollView getter through assembly
        if let calendarViewController = calendarController as? RestaurantBookingCalendarViewController,
            let trackedScrollView = calendarViewController.calendarView?.calendarView {
            calendarViewController.delegate = self
            self.calendarPresentationManager.track(scrollView: trackedScrollView)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let index = self.currentIndex else {
            return
        }
        let context = index == SearchViewController.restaurantBarItemIndex
            ? PageContext.restaurants : PageContext.events
        self.presenter.search(context: context, query: searchText)
    }
}

extension SearchViewController: SearchViewControllerDelegate {
    func updateRestaurantsCount(count: Int) {
        if let bar = self.bars.first,
           let restaurantsItem = bar.items?[safe: SearchViewController.restaurantBarItemIndex] {
            restaurantsItem.badgeValue = "\(count)"
            restaurantsItem.setNeedsUpdate()
        }
    }

    func updateEventsCount(count: Int) {
        if let bar = self.bars.first,
           let eventsItem = bar.items?[safe: SearchViewController.eventsBarItemIndex] {
            eventsItem.badgeValue = "\(count)"
            eventsItem.setNeedsUpdate()
        }
    }

    func updateDeliveryCount(count: Int) {
        if let bar = self.bars.last,
           let deliveryItem = bar.items?[safe: SearchViewController.deliveryBarItemIndex] {
            deliveryItem.badgeValue = "\(count)"
            deliveryItem.setNeedsUpdate()
        }
    }

    func childDidScroll() {
        self.searchView?.endEditing(true)
    }
}

extension SearchViewController: SearchViewDelegate {
    func searchViewDidChooseCalendar(_ view: SearchView) {
        self.presenter.showCalendar()
    }
}

extension SearchViewController: RestaurantBookingCalendarDelegate {
    func calendarDidSelectDate(_ date: Date) {
        self.presenter.search(events: date)
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let index = self.currentIndex else { return true }
        if
            let currentText = textField.text,
            let textRange = Range(range, in: currentText)
        {
            let updatedText = currentText.replacingCharacters(in: textRange, with: string)

            let context = index == SearchViewController.restaurantBarItemIndex
                ? PageContext.restaurants
                : PageContext.events

            presenter.search(context: context, query: updatedText)
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard let index = self.currentIndex else { return true }
        let context = index == SearchViewController.restaurantBarItemIndex
            ? PageContext.restaurants
            : PageContext.events
        presenter.search(context: context, query: "")
        return true
    }
}
