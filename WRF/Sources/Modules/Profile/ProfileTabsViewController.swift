import UIKit
import Tabman
import Pageboy

final class ProfileTabsViewController: TabmanViewController {
    struct Appearance {
        var tabBarWeight: CGFloat = 1
        var tabBarTintColor = Palette.shared.strokeStrong
    }

    private enum Constants {
        enum Tabs: Int {
            case card = 0
            case bookings = 1
            case favorites = 2
        }
    }

    private let appearance: Appearance
    private let tabsContainer: UIView

    private var analyticsEventSendingTimer: Timer?

    private lazy var myCardController: UIViewController = {
        let assembly = MyCardAssembly()
        return assembly.makeModule()
    }()

    private lazy var bookingsController: UIViewController = {
        let assembly = ProfileBookingAssembly()
        return assembly.makeModule()
    }()

    private lazy var favoritesControler = FavoritesAssembly(moduleOutput: self).makeModule()

    private lazy var barItems = [
        WRFBarItem(title: "Моя карта", viewController: myCardController),
        WRFBarItem(title: "История", viewController: bookingsController),
        WRFBarItem(title: "Избранное", viewController: favoritesControler)
    ]

    var tabBar: TMBar.WRFBar?

    init(
        tabsContainer: UIView,
        appearance: Appearance = .init()
    ) {
        self.appearance = appearance
        self.tabsContainer = tabsContainer

        super.init(nibName: nil, bundle: nil)

        setupTabBar()

        Notification.onReceive(.showLoyaltyCard) { [weak self] _ in
            self?.showLoyaltyCard()
        }
        Notification.onReceive(.showBookingHistory) { [weak self] _ in
            self?.showBookingHistory()
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTabBar() {
        let barLocation: BarLocation = .custom(
            view: tabsContainer,
            layout: nil
        )

        if let bar = self.tabBar {
            self.removeBar(bar)
        }

        let bar = makeTabBar()

        self.tabBar = bar
        self.addBar(bar, dataSource: self, at: barLocation)
        self.dataSource = self
    }

    private func makeTabBar() -> TMBar.WRFBar {
        let bar = TMBar.WRFBar()
        bar.layout.interButtonSpacing = 0
        bar.layout.contentMode = .fit
        bar.layout.transitionStyle = .none
        bar.backgroundView.style = .clear
        bar.indicator.weight = .custom(value: appearance.tabBarWeight)
        bar.indicator.tintColorThemed = appearance.tabBarTintColor
        return bar
    }

    func setActiveBookingsCount(_ count: Int) {
        let bar = self.bars.last
        let index = Constants.Tabs.bookings.rawValue
        let historyBarItem = bar?.items?[index]
        let tabBarController = SourcelessRouter().currentTabBarController as? RootTabBarController

        if let historyBarItem, let tabBarController {
            self.tabBar?.buttons.for(item: historyBarItem)?.badgeCount = count
            tabBarController.badgeCount = count
        }
    }

    func showLoyaltyCard() {
        delay(0.3) {
            self.scrollToPage(.at(index: Constants.Tabs.card.rawValue), animated: true)
        }
    }

    func showBookingHistory() {
        delay(0.3) {
            self.scrollToPage(.at(index: Constants.Tabs.bookings.rawValue), animated: true)
        }
    }

    private func debounceAndReportEvent(_ block: @escaping () -> Void) {
        self.analyticsEventSendingTimer?.invalidate()
        self.analyticsEventSendingTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false,
            block: { _ in block() }
            )
    }
}

extension ProfileTabsViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let title = self.barItems[index].title
        return TMBarItem(title: title)
    }

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return self.barItems.count
    }

    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex
    ) -> UIViewController? {
        let viewController = self.barItems[index].viewController

        // added debouncing logic for sending event for analytics once,
        // because delegate methods by default calling twice
        if viewController === bookingsController {
            debounceAndReportEvent {
                AnalyticsReportingService.shared.didTransitionToHistory()
            }
        }
        else if viewController === favoritesControler {
            debounceAndReportEvent {
                AnalyticsReportingService.shared.didTransitionToFavorites()
            }
        }

        return viewController
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}

extension ProfileTabsViewController: FavoritesModuleOutput {
    func updateFavoritesCount(count: Int) {
        let bar = self.bars.first
        let index = Constants.Tabs.favorites.rawValue
        let favoritesItem = bar?.items?[index]

        favoritesItem?.badgeValue = "\(count)"
        favoritesItem?.setNeedsUpdate()
    }
}

extension ProfileTabsViewController: BookingDeeplinkRoutable {
    var nextStoryRoutable: BookingDeeplinkRoutable? {
        return self.bookingsController as? BookingDeeplinkRoutable
    }

    func route(bookingID: HostessBooking.IDType) {
        DispatchQueue.main.async {
            let index = Constants.Tabs.bookings.rawValue

            self.scrollToPage(.at(index: index), animated: false)

            self.nextStoryRoutable?.route(bookingID: bookingID)
        }
    }
}
