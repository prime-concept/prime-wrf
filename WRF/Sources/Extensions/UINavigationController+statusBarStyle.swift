import UIKit

extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
}
