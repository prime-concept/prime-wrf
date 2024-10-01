import SafariServices
import UIKit

// MARK: - Router

final class HomeScreenDeepLinkRouter {
    
    private var eventPresentationManager: FloatingControllerPresentationManager?
    private var restaurantPresentationManager: FloatingControllerPresentationManager?
    
    private unowned let navigationBase: UINavigationController
    
    init(navigationBase: UINavigationController) {
        self.navigationBase = navigationBase
    }
    
}

// MARK: - Routing

extension HomeScreenDeepLinkRouter {
    
    func route(using context: DeeplinkContext) {
        switch context {
        case .booking(let id):
            openBooking(id: id)
        case .event(let id, _):
            openEvent(id: id)
        case .restaurant(let id, _):
            openRestaurant(id: id)
        case .tabbar:
            print("Tab-bar deep links are not supported in the Home Screen navigation mode")
        case .video:
            openVideo()
        case .notifications:
            openNotifications()
        case .delivery(let id):
            openDelivery(id: id)
        case .loyaltyCard:
            openLoyaltyCard()
        case .bookingHistory:
            openBookingHistory()
        case .webView(let url):
            openWebView(url: url)
        case let .chat(token, channelID, channelName, clientID):
            openChat(token: token, channelID: channelID, channelName: channelName, clientID: clientID)
        }
    }
    
    private func openBooking(id: HostessBooking.IDType) {
        guard let profileViewController = ProfileAssembly().makeModule() as? BookingDeeplinkRoutable else {
            print("Missing conformance to the BookingDeeplinkRoutable protocol")
            return
        }
        navigationBase.popToRootViewController(animated: true)
        navigationBase.pushViewController(profileViewController, animated: true)
        profileViewController.route(bookingID: id)
    }
    
    private func openEvent(id: String) {
        let event = Event(id: id)
        let eventAssembly = EventAssembly(event: event)
        let eventPresentationManager = FloatingControllerPresentationManager(
            context: .event,
            groupID: EventsViewController.floatingControllerGroupID,
            sourceViewController: navigationBase,
            grabberAppearance: .light
        )
        
        eventPresentationManager.contentViewController = eventAssembly.makeModule()
        navigationBase.popToRootViewController(animated: true)
        eventPresentationManager.present()
        
        if let trackedScrollView = eventAssembly.trackedScrollView {
            eventPresentationManager.track(scrollView: trackedScrollView)
        }
        
        self.eventPresentationManager = eventPresentationManager
    }
    
    private func openRestaurant(id: String) {
        let restaurant = Restaurant(id: id)
        let restaurantAssembly = RestaurantAssembly(restaurant: restaurant)
        let restaurantController = restaurantAssembly.makeModule()
        
        let restaurantPresentationManager = FloatingControllerPresentationManager(
            context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
            groupID: RestaurantViewController.floatingControllerGroupID,
            sourceViewController: navigationBase
        )
        
        restaurantPresentationManager.contentViewController = restaurantController
        navigationBase.popToRootViewController(animated: true)
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
    
    private func openVideo() {
        navigationBase.popToRootViewController(animated: true)
        NotificationCenter.default.post(name: .videoStartPlay, object: nil)
    }
    
    private func openNotifications() {
        navigationBase.popToRootViewController(animated: true)
        navigationBase.pushViewController(NotificationsAssembly().makeModule(), animated: true)
    }
    
    private func openDelivery(id: String) {
        let controller = WebFrameAssembly(frameData: .restaurant(id: id)).makeModule()
        navigationBase.popToRootViewController(animated: true)
        navigationBase.pushViewController(controller, animated: true)
    }
    
    private func openLoyaltyCard() {
        let profileViewController = ProfileAssembly().makeModule()
        navigationBase.popToRootViewController(animated: true)
        navigationBase.pushViewController(profileViewController, animated: true)
        NotificationCenter.default.post(name: .showLoyaltyCard, object: nil)
    }
    
    private func openBookingHistory() {
        let profileViewController = ProfileAssembly().makeModule()
        navigationBase.popToRootViewController(animated: true)
        navigationBase.pushViewController(profileViewController, animated: true)
        NotificationCenter.default.post(name: .showBookingHistory, object: nil)
    }
    
    private func openWebView(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        navigationBase.popToRootViewController(animated: true)
        navigationBase.present(safariViewController, animated: true)
    }
    
    private func openChat(token: String, channelID: String, channelName: String, clientID: String) {
        let chatAssembly = PGCMain.shared.chatAssemblyConstructor.assembly(
            token: token,
            channelID: channelID,
            channelName: channelName,
            clientID: clientID,
            sourceViewController: navigationBase
        )
        
        let controller = chatAssembly.makeModule()
        navigationBase.popToRootViewController(animated: true)
        navigationBase.present(controller, animated: true, completion: nil)
    }
    
}
