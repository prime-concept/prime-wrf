import UIKit

protocol ProfileBookingInfoControllerPresentatorProtocol: AnyObject {
    func updateHeight(withRating: Bool, withCancel: Bool)
}

final class ProfileBookingInfoControllerPresentator: ProfileBookingInfoControllerPresentatorProtocol {
    private weak var manager: FloatingControllerPresentationManager?
    private let initialContext: FloatingControllerContext

    init(manager: FloatingControllerPresentationManager) {
        self.manager = manager
        self.initialContext = manager.context
    }

    deinit {
        self.manager?.context = self.initialContext
    }

    func updateHeight(withRating: Bool, withCancel: Bool) {
        self.manager?.context = .booking(withRating: withRating, withCancel: withCancel)
    }
}
