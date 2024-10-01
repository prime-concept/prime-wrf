import SafariServices
import UIKit

protocol DeeplinkRouterProtocol: AnyObject {
    func route(context: DeeplinkContext, sourceViewController: UIViewController)
}

final class TabbedDeeplinkRouter: DeeplinkRouterProtocol {
    private var eventPresentationManager: FloatingControllerPresentationManager?
    private var restaurantPresentationManager: FloatingControllerPresentationManager?

    func route(context: DeeplinkContext, sourceViewController: UIViewController) {
        switch context {
        case .event(let id, _):
            self.routeToEvent(id: id, sourceViewController: sourceViewController)
        case .restaurant(let id, _):
            self.routeToRestaurant(id: id, sourceViewController: sourceViewController)
        case .delivery(let id):
            self.routeToDelivery(id: id, sourceViewController: sourceViewController)
        case .booking(let id):
            self.routeToBooking(with: id, sourceViewController: sourceViewController)
        case .notifications:
            self.routeToNotifications(sourceViewController: sourceViewController)
        case .video:
            self.routeToVideo(sourceViewController: sourceViewController)
        case .webView(let url):
            self.open(url: url, sourceViewController: sourceViewController)
        case .chat(let token, let channelID, let channelName, let clientID):
            self.routeToChat(
                token: token,
                channelID: channelID,
                channelName: channelName,
                clientID: clientID,
                sourceViewController: sourceViewController
            )
		case .loyaltyCard:
			self.routeToLoyaltyCard(sourceViewController: sourceViewController)
		case .bookingHistory:
			self.routeToBookingHistory(sourceViewController: sourceViewController)
        default:
            break
        }
    }

    private func routeToEvent(id: String, sourceViewController: UIViewController) {
        let event = Event(id: id)
        let eventAssembly = EventAssembly(event: event)
        let eventPresentationManager = FloatingControllerPresentationManager(
            context: .event,
            groupID: EventsViewController.floatingControllerGroupID,
            sourceViewController: sourceViewController,
            grabberAppearance: .light
        )

        eventPresentationManager.contentViewController = eventAssembly.makeModule()
        eventPresentationManager.present()

        if let trackedScrollView = eventAssembly.trackedScrollView {
            eventPresentationManager.track(scrollView: trackedScrollView)
        }

        self.eventPresentationManager = eventPresentationManager
    }

    private func routeToRestaurant(id: String, sourceViewController: UIViewController) {
        let restaurant = Restaurant(id: id)
        let restaurantAssembly = RestaurantAssembly(restaurant: restaurant)
        let restaurantController = restaurantAssembly.makeModule()

        let restaurantPresentationManager = FloatingControllerPresentationManager(
            context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
            groupID: RestaurantViewController.floatingControllerGroupID,
            sourceViewController: sourceViewController
        )

        restaurantPresentationManager.contentViewController = restaurantController
        restaurantPresentationManager.present()

        if let trackedScrollView = restaurantAssembly.trackedScrollView {
            restaurantPresentationManager.track(scrollView: trackedScrollView)
        }

        if let restaurantViewController = restaurantController as? RestaurantViewController {
            restaurantViewController.restaurantControllerPresentator = RestaurantControllerPresentator(
                manager: restaurantPresentationManager
            )
        }

        self.restaurantPresentationManager = restaurantPresentationManager
    }

    private func routeToDelivery(id: String, sourceViewController: UIViewController) {
        let controller = WebFrameAssembly(frameData: .restaurant(id: id)).makeModule()
        controller.modalPresentationStyle = .fullScreen

        sourceViewController.present(controller, animated: true)
    }

    private func routeToNotifications(sourceViewController: UIViewController) {
        guard let tabBarController = sourceViewController as? RootTabBarController else {
            return
        }

        guard let navigationController = tabBarController.selectedViewController as? UINavigationController else {
            return
        }

        tabBarController.selectedTab = .map

        navigationController.pushViewController(
            NotificationsAssembly().makeModule(),
            animated: true
        )
    }

    private func routeToVideo(sourceViewController: UIViewController) {
        guard let tabBarController = sourceViewController as? RootTabBarController else {
            return
        }

        tabBarController.selectedTab = .events

        NotificationCenter.default.post(name: .videoStartPlay, object: nil)
    }

    private func routeToBooking(with id: HostessBooking.IDType, sourceViewController: UIViewController) {
        guard let sourceViewController = sourceViewController as? BookingDeeplinkRoutable else {
            print("deeplink route: source does not conform story routable protocol")
            return
        }

        sourceViewController.route(bookingID: id)
    }

    private func routeToChat(
        token: String,
        channelID: String,
        channelName: String,
        clientID: String,
        sourceViewController: UIViewController
    ) {
        let chatAssembly = PGCMain.shared.chatAssemblyConstructor.assembly(
            token: token,
            channelID: channelID,
            channelName: channelName,
            clientID: clientID,
            sourceViewController: sourceViewController
        )

        let controller = chatAssembly.makeModule()
        sourceViewController.present(controller, animated: true, completion: nil)
    }

	private func routeToLoyaltyCard(sourceViewController: UIViewController) {
		guard let tabBarController = sourceViewController as? RootTabBarController else {
			return
		}

		tabBarController.selectedTab = .profile
		NotificationCenter.default.post(name: .showLoyaltyCard, object: nil)
	}

	private func routeToBookingHistory(sourceViewController: UIViewController) {
		guard let tabBarController = sourceViewController as? RootTabBarController else {
			return
		}

		tabBarController.selectedTab = .profile
		NotificationCenter.default.post(name: .showBookingHistory, object: nil)
	}

    private func open(url: URL, sourceViewController: UIViewController) {
        let controller = SFSafariViewController(url: url)
        sourceViewController.present(controller, animated: true)
    }
}
