import UIKit

protocol RestaurantControllerPresentatorProtocol: AnyObject {
    func updateHeight(withConfirmation: Bool, withDeposit: Bool, withComment: Bool)
}

final class RestaurantControllerPresentator: RestaurantControllerPresentatorProtocol {
    private weak var manager: FloatingControllerPresentationManager?
    private let initialContext: FloatingControllerContext

    init(manager: FloatingControllerPresentationManager) {
        self.manager = manager
        self.initialContext = manager.context
    }

    deinit {
        self.manager?.context = self.initialContext
    }

    func updateHeight(withConfirmation: Bool, withDeposit: Bool, withComment: Bool) {
        self.manager?.context = .restaurant(
            withConfirmation: withConfirmation,
            withDeposit: withDeposit,
            withComment: withComment
        )
    }
}
