import UIKit

protocol SearchControllerPresentatorProtocol: AnyObject {
    func track(scrollView: UIScrollView?)
}

/// This class is used for updating the 'scrollView' tracked by FloatingControllerPresentationManager,
/// when switching tabs on 'Search' screen
final class SearchControllerPresentator: SearchControllerPresentatorProtocol {
    private weak var manager: FloatingControllerPresentationManager?
    private let initialContext: FloatingControllerContext

    init(manager: FloatingControllerPresentationManager) {
        self.manager = manager
        self.initialContext = manager.context
    }

    deinit {
        self.manager?.context = self.initialContext
    }

    func track(scrollView: UIScrollView?) {
        self.manager?.track(scrollView: scrollView)
    }
}
