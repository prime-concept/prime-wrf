import UIKit

// MARK: - Controller

final class HomeScreenNavigationController: UINavigationController {
    
    private var deepLinkRouter: HomeScreenDeepLinkRouter!
    
    init() {
        let homeScreenViewController = HomeScreenAssembly().makeModule()
        super.init(rootViewController: homeScreenViewController)
        deepLinkRouter = HomeScreenDeepLinkRouter(navigationBase: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - RootModule

extension HomeScreenNavigationController: RootModule {
    
    func route(using context: DeeplinkContext) {
        deepLinkRouter.route(using: context)
    }
    
}
