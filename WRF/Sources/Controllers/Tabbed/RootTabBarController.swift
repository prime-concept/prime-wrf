import SnapKit
import UIKit

extension Notification.Name {
	static let wrfTabChanged = Notification.Name(rawValue: "WRFTabChanged")
}

private class ShadowlessNavbar: UINavigationBar {
	override func layoutSubviews() {
		super.layoutSubviews()
		self.hideShadow()
	}

	func hideShadow() {
		let imageView = self.firstSubview(like: "shadow")
		imageView?.isHidden = true
	}
}

extension UIView {
	func firstSubview<T: UIView>(_ type: T.Type) -> T? {
		for subview in self.subviews {
			if subview is T {
				return subview as? T
			}

			if let view = subview.firstSubview(type) {
				return view
			}
		}

		return nil
	}

	func firstSubview(like className: String) -> UIView? {
		for subview in self.subviews {
			let subviewClassName = NSStringFromClass(type(of: subview)).lowercased()
			if subviewClassName.contains(className.lowercased()) {
				return subview
			}

			if let view = subview.firstSubview(like: className) {
				return view
			}
		}

		return nil
	}
}

extension RootTabBarController {
    struct Appearance {
        let backgroundColor = UIColor.white
        let tintColor = PGCMain.shared.palette.tintColor
        let unselectedTintColor = UIColor(red: 0.867, green: 0.843, blue: 0.796, alpha: 1)
        let tabBarItemLabelFont = UIFont.wrfFont(ofSize: 10, weight: .regular)

        let mainTabDotSizeHeight: CGFloat = 6
        let tabBarItemLabelOffset = UIOffset(horizontal: 0, vertical: -5.5)
        var mainTabItemLabelOffset = UIOffset(horizontal: 0, vertical: -5.5)
        let mainTabDotVisibleHeight: CGFloat = 4
        var mainTabImageInset = UIEdgeInsets.zero

        let badgeLabelColor = UIColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        let badgeLabelTextColor = UIColor.white
        let badgeLabelFont = UIFont.wrfFont(ofSize: 10, weight: .bold)
        let badgeLabelTextInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        let badgeLabelCornerRadius: CGFloat = 6
    }
}

final class RootTabBarController: UITabBarController {
    static let appearance: Appearance = ApplicationAppearance.appearance()

    enum Tabs: Int {
        case events = 0
        case map = 1
        case profile = 2

        init?(from value: String) {
            switch value {
            case "events":
                self = .events
            case "map", "home":
                self = .map
            case "profile":
                self = .profile
            default:
                return nil
            }
        }
    }
    
    let deeplinkRouter: any DeeplinkRouterProtocol = TabbedDeeplinkRouter()

    private static let mainTabIndex = Tabs.map.rawValue
    private static let profileTabIndex = Tabs.profile.rawValue

    private lazy var mainTabDotIndicator: UIView = {
        let view = UIView()
		view.backgroundColor = .clear
        return view
    }()

    private lazy var badgeLabel: UILabel = {
        let label = PaddingLabel()
        label.font = Self.appearance.badgeLabelFont
        label.backgroundColor = Self.appearance.badgeLabelColor
        label.textColor = Self.appearance.badgeLabelTextColor
        label.insets = Self.appearance.badgeLabelTextInsets
        label.layer.cornerRadius = Self.appearance.badgeLabelCornerRadius
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()

    private lazy var profileViewController = ProfileAssembly().makeModule()

    override var selectedViewController: UIViewController? {
        didSet {
            self.mainTabDotIndicator.isHidden = self.selectedIndex != RootTabBarController.mainTabIndex
            if self.selectedIndex == Tabs.profile.rawValue {
                AnalyticsReportingService.shared.didTransitionToProfile()
            }
        }
    }

    var selectedTab: Tabs? {
        didSet {
            self.selectedTab.flatMap {
                self.selectedIndex = $0.rawValue
            }
			NotificationCenter.default.post(.wrfTabChanged)
        }
    }

    var badgeCount: Int = 0 {
        didSet {
            self.badgeLabel.text = "\(self.badgeCount)"
            self.badgeLabel.isHidden = self.badgeCount == 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTabs()
        self.setupAppearance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupMainTabIndicator()
        self.setupBadge()
    }

    // MARK: - Private API

    private func setupTabs() {
        // Events
        let eventsTabItem = UITabBarItem(
            title: "События",
            image: #imageLiteral(resourceName: "first-tab"),
            selectedImage: #imageLiteral(resourceName: "first-tab-selected")
        )
        let eventsAssembly = EventsAssembly()
        let eventsController = UINavigationController(rootViewController: eventsAssembly.makeModule())
        eventsController.tabBarItem = eventsTabItem

        // Main
        let mainTabItem = UITabBarItem(
            title: PGCMain.shared.featureFlags.tabBar.shouldUseStaticTitle
                ? "Gourmet"
                : "Рестораны",
            image: #imageLiteral(resourceName: "main-tab"),
            selectedImage: #imageLiteral(resourceName: "main-tab-selected")
        )
        mainTabItem.imageInsets = Self.appearance.mainTabImageInset
        let mapAssembly = MapAssembly()
        let mainController = UINavigationController(rootViewController: mapAssembly.makeModule())
        mainController.isNavigationBarHidden = true
        mainController.tabBarItem = mainTabItem

        // Profile
        let profileTabItem = UITabBarItem(
            title: "Профиль",
            image: #imageLiteral(resourceName: "third-tab"),
            selectedImage: #imageLiteral(resourceName: "third-tab-selected")
        )
		let profileController = UINavigationController(navigationBarClass: ShadowlessNavbar.self, toolbarClass: nil)
		profileController.viewControllers = [self.profileViewController]
        profileController.tabBarItem = profileTabItem

        [eventsTabItem, profileTabItem].forEach {
            $0.titlePositionAdjustment = Self.appearance.tabBarItemLabelOffset
        }
        mainTabItem.titlePositionAdjustment = Self.appearance.mainTabItemLabelOffset

        self.viewControllers = [eventsController, mainController, profileController]
        self.selectedIndex = RootTabBarController.mainTabIndex
    }

    private func setupAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Self.appearance.backgroundColor

            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
        }

        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = Self.appearance.tintColor
        self.tabBar.barTintColor = Self.appearance.backgroundColor

        // swiftlint:disable colon
        self.tabBar.unselectedItemTintColor = PGCMain.shared.featureFlags.tabBar.shouldUseUnselectedColor
            ? Self.appearance.unselectedTintColor
            : Self.appearance.tintColor
        // swiftlint:enable colon

        UITabBarItem.appearance(whenContainedInInstancesOf: [RootTabBarController.self]).setTitleTextAttributes(
            [
                .foregroundColor: Self.appearance.tintColor,
                .font: Self.appearance.tabBarItemLabelFont
            ],
            for: .normal
        )
    }

    private func setupMainTabIndicator() {
        if PGCMain.shared.featureFlags.tabBar.shouldUseStaticTitle {
            return
        }
        let tabBarButtons = self.tabBar.subviews.filter { NSStringFromClass(type(of: $0)) == "UITabBarButton" }
        guard let mainTabBarButton = tabBarButtons[safe: RootTabBarController.mainTabIndex] else {
            return
        }

        self.mainTabDotIndicator.translatesAutoresizingMaskIntoConstraints = false
        mainTabBarButton.addSubview(self.mainTabDotIndicator)
        self.mainTabDotIndicator.snp.makeConstraints { make in
            make.height.width.equalTo(Self.appearance.mainTabDotSizeHeight)
            make.centerX.equalToSuperview()
            make.bottom
                .equalToSuperview()
                .offset(Self.appearance.mainTabDotSizeHeight - Self.appearance.mainTabDotVisibleHeight)
        }
        self.mainTabDotIndicator.clipsToBounds = true
        self.mainTabDotIndicator.layer.cornerRadius = Self.appearance.mainTabDotSizeHeight / 2
        mainTabBarButton.clipsToBounds = true

        self.mainTabDotIndicator.isHidden = self.selectedIndex != RootTabBarController.mainTabIndex
    }

    private func setupBadge() {
        let tabBarButtons = self.tabBar.subviews.filter { NSStringFromClass(type(of: $0)) == "UITabBarButton" }
        guard let profileTabBarButton = tabBarButtons[safe: RootTabBarController.profileTabIndex] else {
            return
        }

        profileTabBarButton.addSubview(self.badgeLabel)
        self.badgeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(1)
        }
    }
}

extension RootTabBarController: BookingDeeplinkRoutable {
    var nextStoryRoutable: BookingDeeplinkRoutable? {
        return self.profileViewController as? BookingDeeplinkRoutable
    }

    func route(bookingID: HostessBooking.IDType) {
        self.selectedIndex = Tabs.profile.rawValue
        self.nextStoryRoutable?.route(bookingID: bookingID)
    }
}
