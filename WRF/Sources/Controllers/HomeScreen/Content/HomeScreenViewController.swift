import DeviceKit
import UIKit
import FloatingPanel

protocol HomeScreenViewControllerProtocol: UIViewController {
	func set(banner viewModel: BannerViewModel?)
	func set(events: [EventCellViewModel])
    func set(restaurants: [MapRestaurantViewModel])
    func setNotificationsButton(hidden: Bool, count: Int)

    func present(restaurant: Restaurant, assessment: PrimePassAssessment?)
    func showLocationSettings()
    func handleUnauthorizedUser(completion: (() -> Void)?)
    func showLoading()
    func hideLoading()
}

final class HomeScreenViewController: UIViewController {
    enum Appearance {
        private static let bannerWHRatio = CGFloat(UIApplication.shared.windows.first?.bounds.width ?? 375) / 375
        static let bannerHeight: CGFloat = ceil(473 * bannerWHRatio)
		static let eventsCarouselHeight: CGFloat = 239
		static let restaurantCellHeight: CGFloat = 104

        static let defaultTopOffset: CGFloat = 15
        static let smallTopOffset: CGFloat = 8
        
        static let restaurantsContainerHeight: CGFloat = 350
        static let largeRestaurantsContainerHeight: CGFloat = 446

        static let citiesCurtainHeight: CGFloat = UIScreen.main.bounds.height - 150
        static let citiesViewBackgroundColor = Palette.shared.backgroundColor0
    }
    
    static var currentRestaurantsContainerHeight: CGFloat {
        return Device.current.diagonal >= 5.5
        ? Appearance.largeRestaurantsContainerHeight
        : Appearance.restaurantsContainerHeight
    }

    private var currentCity: SearchCityViewModel?

    let presenter: HomeScreenPresenterProtocol
    lazy var homeScreenView = view as? HomeScreenView

    private lazy var restaurantPresentationManager = FloatingControllerPresentationManager(
        context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
        groupID: RestaurantViewController.floatingControllerGroupID,
        sourceViewController: self
    )
    
    private lazy var searchPresentationManager = FloatingControllerPresentationManager(
        context: .search(height: SearchViewController.Appearance.controllerHeight),
        groupID: SearchViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )
    
    private lazy var filterPresentationManager = FloatingControllerPresentationManager(
        context: .filter,
        groupID: MapFilterViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private lazy var notificationsBarButtonItem = HomeScreenNavbarItemView.barButtonItem(
        image: PGCResources.Images.HomeScreen.notificationsIcon
    ) { [weak self] in
        self?.homeScreenViewDidSelectNotifications()
    }

	private var banner: BannerViewModel?

	private var events: [EventCellViewModel] = []
	private var mustReloadEvents = true

    private var restaurants: [MapRestaurantViewModel] = []
    
    init(presenter: HomeScreenPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = HomeScreenView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

		configureNavigationItem()
        
		presenter.didLoad()
    }

	private func configureNavigationItem() {
        let titleView = UIImageView(image: PGCResources.Images.HomeScreen.logo)
        navigationItem.titleView = titleView

		let profileItem = UIBarButtonItem(
			image: PGCResources.Images.HomeScreen.profileIcon,
			style: .plain,
			target: self,
			action: #selector(didTapProfileItem)
		)
        profileItem.tintColorThemed = Palette.shared.iconsPrimary
		navigationItem.leftBarButtonItem = profileItem
        navigationItem.setBackButtonText()
        notificationsBarButtonItem.tintColorThemed = Palette.shared.iconsPrimary

        navigationItem.rightBarButtonItem = notificationsBarButtonItem

        edgesForExtendedLayout = [.top]

        homeScreenView?.restaurantsTableView.contentInsetAdjustmentBehavior = .never
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let bottom = view.window?.safeAreaInsets.bottom
        homeScreenView?.restaurantsTableView.contentInset.bottom = bottom ?? 0
    }

	// MARK: UI Actions

	@objc private func didTapProfileItem() {
		let profileViewController = ProfileAssembly().makeModule()
		navigationController?.pushViewController(profileViewController, animated: true)
	}

    // MARK: - Private API
    
    private func openSettingsDialog(title: String, message: String?) {
        let dialog = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let settingsAction = UIAlertAction(title: "Перейти", style: .default) { _ in
            if let url = URL(string: "\(UIApplication.openSettingsURLString)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        dialog.addAction(cancelAction)
        dialog.addAction(settingsAction)
        dialog.popoverPresentationController?.sourceView = view
        present(dialog, animated: true)
    }
}

extension HomeScreenViewController: UITableViewDelegate {}

extension HomeScreenViewController: UITableViewDataSource {
	struct Sections {
		static let banner = 0
		static let events = 1
		static let restaurants = 2
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == Sections.events, !events.isEmpty {
			return 24
		}
		return 0
	}

	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		if section == Sections.events, !events.isEmpty {
			return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 24))
		}

		return nil
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == Sections.banner {
			return banner == nil ? 0 : Appearance.bannerHeight
		}
		if indexPath.section == Sections.events {
			return events.isEmpty ? 0 : Appearance.eventsCarouselHeight
		}
		if indexPath.section == Sections.restaurants {
			return restaurants.isEmpty ? 0 : Appearance.restaurantCellHeight
		}

		return 0
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		3
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == Sections.banner {
			return banner == nil ? 0 : 1
		}
		if section == Sections.events {
			return events.isEmpty ? 0 : 1
		}
		if section == Sections.restaurants {
			return restaurants.count
		}

		return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == Sections.banner {
			let cell: BannerViewCell = tableView.dequeueReusableCell(for: indexPath)
			if let banner = banner {
				cell.update(with: banner)
			}
			return cell
		}

		if indexPath.section == Sections.events {
			let cell: HomeScreenEventsCell = tableView.dequeueReusableCell(for: indexPath)
			cell.didSelectEvent = { [weak self] id in
				self?.presenter.didSelectEvent(id: id)
			}
			cell.didToggleFavorite = { [weak self] id, isFavorite in
				self?.presenter.didToggleFavorite(eventId: id, favorite: isFavorite)
			}
			cell.didScrollToEnd = { [weak self] in
                self?.presenter.loadMoreEvents(withCityID: self?.currentCity?.id)
			}
			if mustReloadEvents {
				mustReloadEvents = false
				cell.update(with: events)
			}
			return cell
		}

        let cell: MapRestaurantsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? MapRestaurantsTableViewCell,
           let viewModel = self.restaurants[safe: indexPath.row] {
            cell.configure(with: viewModel, isSmall: Device.current.diagonal <= 4.0)
            return
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == Sections.restaurants {
            let viewModel = restaurants[indexPath.row]
            presenter.selectRestaurant(id: viewModel.id)
		}
    }
}

extension HomeScreenViewController: HomeScreenViewDelegate {
    @objc
    func homeScreenViewDidSelectNotifications() {
        let notificationsController = NotificationsAssembly().makeModule()
        navigationController?.pushViewController(notificationsController, animated: true)
        setNotificationsButton(hidden: false, count: 0)
        presenter.didTransitionToNotifications()
    }

	func homeScreenViewDidToggleFavorite(eventId: Event.IDType, favorite: Bool) {
		presenter.didToggleFavorite(eventId: eventId, favorite: favorite)
	}

	func homeScreenViewDidSelectEvent(id: Event.IDType) {
		presenter.didSelectEvent(id: id)
	}

    func homeScreenViewOpenCitySelection(_ view: HomeScreenView) {
        let assembly = SearchCityAssembly()
        assembly.selectedCity = currentCity

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
            self?.homeScreenView?.setupCityButton(with: city.title)
            self?.presenter.loadMoreEvents(withCityID: city.id)
            self?.presenter.loadRestaurants(withCityID: city.id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                curtain.dismiss(animated: true)
            }
        }

        curtain.present(animated: false)
    }

    func homeScreenViewOpenSearch(_ view: HomeScreenView) {
        presenter.didActivateSearchMode()

        let searchController = SearchAssembly().makeModule()
        searchPresentationManager.contentViewController = searchController
        searchPresentationManager.present()

        if let searchViewController = searchController as? SearchViewController {
            searchViewController.searchControllerPresentator = SearchControllerPresentator(
                manager: searchPresentationManager
            )
        }
    }

    func homeScreenViewOpenMap(_ view: HomeScreenView) {
        let vc = MapAssembly().makeModule()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension HomeScreenViewController: HomeScreenViewControllerProtocol {
	func set(events: [EventCellViewModel]) {
        self.events = events
		mustReloadEvents = true
		homeScreenView?.updateTableView(delegate: self, dataSource: self)
		homeScreenView?.hideLoading()
	}

    func set(restaurants: [MapRestaurantViewModel]) {
        self.restaurants = restaurants
        homeScreenView?.updateTableView(delegate: self, dataSource: self)
        homeScreenView?.hideLoading()
    }

	func set(banner viewModel: BannerViewModel?) {
		banner = viewModel
		homeScreenView?.updateTableView(delegate: self, dataSource: self)
        homeScreenView?.hideLoading()
	}

    func setNotificationsButton(hidden: Bool, count: Int) {
        let customView = notificationsBarButtonItem.customView as? HomeScreenNavbarItemView
        let badgeText = count > 0 ? "\(count)" : nil

        customView?.update(with: .init(
            image: PGCResources.Images.HomeScreen.notificationsIcon,
            badgeText: badgeText
        ))

        navigationItem.rightBarButtonItem = hidden ? nil : notificationsBarButtonItem
    }
    
    func present(restaurant: Restaurant, assessment: PrimePassAssessment?) {
        let assembly = RestaurantAssembly(restaurant: restaurant, assessment: assessment)
        let restaurantController = assembly.makeModule()

        restaurantPresentationManager.contentViewController = restaurantController
        restaurantPresentationManager.present()

        if let restaurantViewController = restaurantController as? RestaurantViewController {
            restaurantViewController.restaurantControllerPresentator = RestaurantControllerPresentator(
                manager: restaurantPresentationManager
            )
            restaurantPresentationManager.track(scrollView: assembly.trackedScrollView)
        }
    }

    func showLocationSettings() {
        openSettingsDialog(
            title: "Запрос на уведомления",
            message: "Изменить параметры уведомлений в настройках"
        )
    }

	func handleUnauthorizedUser(completion: (() -> Void)?) {
		let moduleController = AuthAssembly(onAuthorize: completion).makeModule()
		present(moduleController, animated: true)
	}

    func showLoading() {
        DispatchQueue.main.async {
            self.homeScreenView?.showLoading()
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.homeScreenView?.hideLoading()
        }
    }
}
