import UIKit

/// The object managing the user interface in response to opened deep links.
protocol DeepLinkUIRouter: UIViewController {
    
    /// Navigates the user to the screen matching the deep link.
    func route(using context: DeeplinkContext)
    
}
