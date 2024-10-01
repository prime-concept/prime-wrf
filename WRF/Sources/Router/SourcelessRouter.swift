import UIKit

open class SourcelessRouter {
    open var window: UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }
        return nil
    }

    public init() {}

    var currentNavigationController: UINavigationController? {
        guard let tabBarController = self.currentTabBarController,
              let viewControllers = tabBarController.viewControllers else {
            return nil
        }

        guard viewControllers.count > tabBarController.selectedIndex else {
            return nil
        }
        
        return viewControllers[tabBarController.selectedIndex] as? UINavigationController
    }

    open var topController: UIViewController? {
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

    var currentTabBarController: UITabBarController? {
        return self.window?.rootViewController as? UITabBarController
    }
}
