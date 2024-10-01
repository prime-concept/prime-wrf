extension RootTabBarController: RootModule {
    
    func route(using context: DeeplinkContext) {
        switch context {
        case .booking, .notifications, .video:
            deeplinkRouter.route(context: context, sourceViewController: self)
        case .webView, .chat, .event, .restaurant, .delivery:
            guard let topController = AppDelegate.shared.topController else {
                return assertionFailure("Could not get topController from AppDelegate")
            }
            deeplinkRouter.route(context: context, sourceViewController: topController)
        case .tabbar(let page):
            selectedTab = page
        case .loyaltyCard:
            selectedTab = RootTabBarController.Tabs.profile
            NotificationCenter.default.post(name: .showLoyaltyCard, object: nil)
        case .bookingHistory:
            selectedTab = RootTabBarController.Tabs.profile
            NotificationCenter.default.post(name: .showBookingHistory, object: nil)
        }
    }
    
}
