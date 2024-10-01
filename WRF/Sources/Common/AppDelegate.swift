import Branch
import Firebase
import FirebaseMessaging
import GoogleMaps
import Nuke
import UIKit
import UserNotifications
import YandexMobileMetrica

open class AppDelegate: UIResponder, UIApplicationDelegate {
    private static let tabBarPresentationDelay: TimeInterval = 1.5
    private static let imageCacheContainerName = "wrf.image-cache"

    public var window: UIWindow?
    static var shared: AppDelegate!

    private let appLinkParser = AppLinkParser()
	private var pendingDeepLinkOpener: (() -> Void)?

    private let defaultsService = DefaultsService()
    private lazy var appVersionUpdateService = AppVersionUpdateService()
    private weak var rootModuleContainer: (any RootModuleContainer)?

    private let syncOperationSemaphore = DispatchSemaphore(value: 0)
    private let syncOperationQueue = DispatchQueue(label: "appdelegate.operation")

    var topController: UIViewController? {
        func findNextController(controller: UIViewController) -> UIViewController? {
            if
                let tabBarController = controller as? UITabBarController,
                let selected = tabBarController.selectedViewController
            {
                return selected
            }

            if
                let navigationController = controller as? UINavigationController,
                let top = navigationController.topViewController
            {
                return top
            }

            return controller.presentedViewController
        }

        guard
            let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController
        else {
            return nil
        }

        var topController = rootViewController

        while let newTopController = findNextController(controller: topController) {
            topController = newTopController
        }

        return topController
    }
    
    override init() {
        super.init()
        
        Self.shared = self
    }
    
    open func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        Palette.shared.updateFrom(file: "Palette", ofType: ".json")
        Theme.shared.updateFrom(file: "Theme", ofType: ".json")
        return true
    }

    public func application(
        _ application: UIApplication,
        // swiftlint:disable:next discouraged_optional_collection
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
		self.setupUserDefaults()
		
        AnalyticsService.setupAnalytics()
        self.setupGoogleServices()
        self.setupAppearance()
        self.setupPushes()
		self.subscribeToNotifications()
        self.setupImageCaching()
		self.setupBranch(with: launchOptions)
		self.setupPluralization()
		self.appVersionUpdateService.resetAuthIfNeeded()

		self.window = WRFWindow(frame: UIScreen.main.bounds)
        presentRootModule()

        return true
    }

    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
		var didOpen = Branch.getInstance().application(app, open: url, options: options)
		didOpen = didOpen || self.openPlainDeeplinkIfPossible(url)

        return didOpen
    }

    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        // swiftlint:disable:next discouraged_optional_collection
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        Branch.getInstance().continue(userActivity)
        return true
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    // MARK: - Private API

	private func setupBranch(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
		Branch.getInstance().initSession(launchOptions: launchOptions) { params, _ in
			guard let data = params as? [String: AnyObject] else {
				return
			}

			self.appLinkParser.tryToOpen(data: data) { [weak self] context in
				guard let context = context else {
					return
				}
				self?.handleDeeplink(context: context)
			}
		}
	}

	private func subscribeToNotifications() {
		Notification.onReceive(UIApplication.didBecomeActiveNotification) { [weak self] _ in
			self?.pendingDeepLinkOpener?()
			self?.pendingDeepLinkOpener = nil
		}
	}

    private func handleDeeplink(context: DeeplinkContext) {
		let block = {
			self.syncOperationQueue.async {
				defer {
					self.syncOperationSemaphore.signal()
				}
				self.syncOperationSemaphore.wait()
                Task { [weak self] in
                    await self?.rootModuleContainer?.handleDeepLink(context)
                }
			}
		}

		if UIApplication.shared.applicationState == .active {
			block()
			return
		}

		self.pendingDeepLinkOpener = block
    }

	@discardableResult
	private func openPlainDeeplinkIfPossible(_ url: URL) -> Bool {
		let didOpenPlainDeeplink = self.appLinkParser.tryToOpen(
			url: url,
			completion: { [weak self] context in
				guard let context = context else {
					return
				}
				self?.handleDeeplink(context: context)
			}
		)

		return didOpenPlainDeeplink
	}

    private func setupPushes() {
        UNUserNotificationCenter.current().delegate = self
    }

    private func setupGoogleServices() {
        GMSServices.provideAPIKey(PGCMain.shared.config.googleMapsKey)

        // Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }

    private func setupAppearance() {
        UINavigationBar.setupAppearance()
    }

    private func setupImageCaching() {
        let pipeline = ImagePipeline {
            $0.dataCache = try? DataCache(name: AppDelegate.imageCacheContainerName)
        }
        ImagePipeline.shared = pipeline
    }

    private func presentRootModule() {
        defer {
            self.syncOperationSemaphore.signal()
        }
        
        let rootModuleContainer = RootModuleContainerViewController()
        window?.rootViewController = rootModuleContainer
        window?.makeKeyAndVisible()
        self.rootModuleContainer = rootModuleContainer
    }

	private func setupUserDefaults() {
		UserDefaults.standard.register(
			defaults: [
				"CertsEnabled": true,
				"CaptchaProd": !Bundle.isTestFlightOrSimulator,
				"CaptchaDebug": Bundle.isTestFlightOrSimulator
			]
		)
	}
}

// MARK: - FCM delegate

extension AppDelegate: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
		UserDefaults[string: "FCM_TOKEN"] = fcmToken

        print("fcm token received: \(fcmToken ?? "fcmToken has not been received")")

        // User already authorized -> try to update user ID in register service and trigger remote update
        if let userID = AuthService().authorizationData?.userID {
            NotificationsTokenRegisterService.shared.update(userID: userID)
        }

        if let fcmToken = fcmToken {
            NotificationsTokenRegisterService.shared.update(token: fcmToken)
        }
    }
}

// MARK: - Notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }

    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer {
            completionHandler()
        }

        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)

		var urlPath = (userInfo["data"] as? [String: AnyObject])?["url"] as? String
		urlPath = urlPath ?? userInfo["url"] as? String

		guard let urlPath = urlPath,
			  let url = URL(string: urlPath) else {
			return
		}

		if Branch.getInstance().handleDeepLink(url) {
			return
		}

		UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
