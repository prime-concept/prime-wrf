import FloatingPanel
import SnapKit
import UIKit

enum FloatingControllerContext {
    case restaurant(withConfirmation: Bool, withDeposit: Bool, withComment: Bool)
    case checkout(showDeposit: Bool)
    case calendar
    case filter
    case feedback
    case booking(withRating: Bool, withCancel: Bool)
    case myCard
    case event
    case eventWeb
    case search(height: CGFloat)
    case payment(keyboardHeight: CGFloat)
    case menu

    fileprivate var initialPosition: FloatingPanelPosition {
        switch self {
        case .menu, .feedback, .restaurant, .eventWeb:
            .full
        case .event:
            PGCMain.shared.featureFlags.map.showMapSearch ? .full : .half
        case .search:
            PGCMain.shared.featureFlags.searching.halfPosition ? .half : .full
        default:
            .half
        }
    }

    var isFullPositionSupported: Bool {
        switch self {
        case .restaurant, .feedback, .search, .menu, .eventWeb:
            true
        case .calendar, .checkout:
            false
        case .event:
            PGCMain.shared.featureFlags.map.showMapSearch
        default:
            false
        }
    }

    var isRealFullPositionSupported: Bool {
        switch self {
        case .menu, .eventWeb:
            return true
        default:
            return false
        }
    }

    var isHalfPositionSupported: Bool {
        switch self {
        case .restaurant:
            false
        case .event:
            false
        case .search:
            PGCMain.shared.featureFlags.searching.halfPosition
        default:
            true
        }
    }

    var insetForHalfPosition: CGFloat {
        switch self {
        case .restaurant(let withConfirmation, let withDeposit, let withComment):
            switch (withConfirmation, withDeposit, withComment) {
            case (true, true, _):
                return 676
            case (true, false, _):
                return 597
            case (false, _, _):
                return 542
            }
        case .checkout(let showDeposit):
            return showDeposit ? 443 : 362
        case .calendar:
            return 352
        case .filter:
            return 272
        case .feedback:
            return 430
        case .booking(let withRating, let withCancel):
            var height = 380
            if withRating {
                height += 69
            }
            if withCancel {
                height += 80
            }
            return CGFloat(height)
        case .myCard:
            return 381
        case .event:
            return 542
        case .payment(let keyboardHeight):
            return 294 + keyboardHeight
        case .search(let height):
            return height
        case .menu, .eventWeb:
            return 542
        }
    }
}

final class FloatingControllerPresentationManager {
    enum Appearance {
        static let backgroundColor = Palette.shared.backgroundColor0

        static let overlayAlpha: CGFloat = 0.7
        static let cornerRadius: CGFloat = 15

        static let grabberViewSize = CGSize(width: 40, height: 4)
        static let grabberViewCornerRadius: CGFloat = Appearance.grabberViewSize.height / 2
        static let grabberViewInsets = LayoutInsets(top: 10)

        static let minimizationOffset: CGFloat = 50
        static let animationDuration: TimeInterval = 0.25
    }

    let groupID: String?
    var contentViewController: UIViewController?
    let sourceViewController: UIViewController
    private let shouldMinimizePreviousController: Bool
    private let grabberAppearance: GrabberAppearance?

    var context: FloatingControllerContext {
        didSet {
            UIView.animate(withDuration: Appearance.animationDuration) {
                self.floatingController.updateLayout()
            }
        }
    }

    // State – view controller is minimized
    fileprivate var isMinimized = false
    fileprivate var minimizationInset: CGFloat?
    fileprivate var currentPosition: FloatingPanelPosition = .half

    private lazy var grabberView: UIView = {
        let grabberView = UIView()
        grabberView.isUserInteractionEnabled = false
        grabberView.backgroundColor = self.grabberAppearance?.viewColor ?? .clear
        grabberView.clipsToBounds = true
        grabberView.layer.cornerRadius = Appearance.grabberViewCornerRadius
        grabberView.isHidden = self.grabberAppearance == nil
        return grabberView
    }()

    private lazy var floatingController: FloatingPanelController = {
        let controller = FloatingPanelController(delegate: self)
        controller.surfaceView.cornerRadius = Appearance.cornerRadius
        controller.surfaceView.shadowHidden = true
        controller.isRemovalInteractionEnabled = true
        controller.surfaceView.backgroundColorThemed = Appearance.backgroundColor

        controller.surfaceView.grabberHandle.isHidden = true

        let grabberView = self.grabberView
        controller.surfaceView.addSubview(grabberView)
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        grabberView.snp.makeConstraints { make in
            make.size.equalTo(Appearance.grabberViewSize)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Appearance.grabberViewInsets.top)
        }

        return controller
    }()

    /// Position in modal stack (value 0 means top controller)
    private(set) var modalStackPosition: Int = 0

    var controllerID: String {
        return "\(self.floatingController.hashValue)"
    }

    var contentInsetAdjustmentBehavior: FloatingPanelController.ContentInsetAdjustmentBehavior = .always {
        didSet {
            self.floatingController.contentInsetAdjustmentBehavior = self.contentInsetAdjustmentBehavior
        }
    }

    private var notificationUserInfo: [String: Any] {
        var userInfo: [String: Any] = [
            NotificationKey.controllerID.rawValue: self.controllerID,
            NotificationKey.shouldMinimizePreviousController.rawValue: self.shouldMinimizePreviousController
        ]
        userInfo[NotificationKey.groupID.rawValue] = self.groupID
        return userInfo
    }

    init(
        context: FloatingControllerContext,
        groupID: String? = nil,
        contentViewController: UIViewController? = nil,
        sourceViewController: UIViewController,
        shouldMinimizePreviousController: Bool = false,
        grabberAppearance: GrabberAppearance? = .dark
    ) {
        self.context = context
        self.groupID = groupID
        self.contentViewController = contentViewController
        self.sourceViewController = sourceViewController
        self.shouldMinimizePreviousController = shouldMinimizePreviousController
        self.grabberAppearance = grabberAppearance

		Notification.onReceive(.wrfTabChanged) { [weak self] _ in
			DispatchQueue.main.async {
				self?.floatingController.dismiss(animated: true)
			}
		}
    }

    deinit {
        if self.floatingController.position != .hidden {
            assertionFailure("Active floating controller deallocated")
        }
    }

    // MARK: - Public API

    func track(scrollView: UIScrollView?) {
        self.floatingController.track(scrollView: scrollView)
    }

    func move(to position: FloatingPanelPosition) {
        guard position != self.currentPosition else {
            return
        }
        UIView.animate(withDuration: Appearance.animationDuration) {
            self.floatingController.move(to: position, animated: false)
        }
    }

    func present() {
        precondition(self.floatingController.parent == nil)

        // Reset state
        self.isMinimized = false
        self.minimizationInset = nil
        self.registerForNotifications()

        // Add inset to use it for minimization
        var userInfo = self.notificationUserInfo
        let layout = self.floatingPanel(self.floatingController, layoutFor: self.sourceViewController.traitCollection)
        let initialPosition = layout?.initialPosition ?? .half
        let inset = layout?.insetFor(position: initialPosition)
        userInfo[NotificationKey.inset.rawValue] = inset

        NotificationCenter.default.post(
            name: FloatingControllerPresentationManager.floatingControllerDidPresent,
            object: nil,
            userInfo: userInfo
        )

        guard self.floatingController.presentingViewController == nil else {
            print("floating presentation manager: presenting controller is not null")
            return
        }
        self.floatingController.set(contentViewController: self.contentViewController)
        self.sourceViewController.present(self.floatingController, animated: true, completion: nil)
    }

    // MARK: - Private API

    @objc
    private func handlePresentation(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        if let groupID = userInfo[NotificationKey.groupID.rawValue] as? String,
           groupID != self.groupID {
            return
        }

        if let controllerID = userInfo[NotificationKey.controllerID.rawValue] as? String,
           controllerID == self.controllerID {
            return
        }

        self.modalStackPosition += 1

        // Minimize only next after top controller
        guard self.modalStackPosition == 1 else {
            return
        }

        let key = NotificationKey.shouldMinimizePreviousController.rawValue
        guard let shouldMinimizeController = userInfo[key] as? Bool, shouldMinimizeController else {
            return
        }

        self.isMinimized = true
        if let inset = userInfo[NotificationKey.inset.rawValue] as? CGFloat {
            self.minimizationInset = inset - Appearance.minimizationOffset
        }
        self.floatingController.updateLayout()

        self.floatingController.move(to: .tip, animated: true)
    }

    @objc
    private func handleDismission(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        if let groupID = userInfo[NotificationKey.groupID.rawValue] as? String,
            groupID != self.groupID {
            return
        }

        if let controllerID = userInfo[NotificationKey.controllerID.rawValue] as? String,
           controllerID == self.controllerID {
            self.floatingController.set(contentViewController: nil)
            self.contentViewController?.removeFromParent()
            self.contentViewController = nil
            return
        }

        self.modalStackPosition -= 1
        guard self.modalStackPosition == 0 else {
            return
        }

        let key = NotificationKey.shouldMinimizePreviousController.rawValue
        guard let shouldMinimizeController = userInfo[key] as? Bool, shouldMinimizeController else {
            return
        }

        self.isMinimized = false
        self.minimizationInset = nil

        let restoredPosition = self.floatingPanel(
            self.floatingController, layoutFor: self.sourceViewController.traitCollection
        )?.initialPosition ?? .half
        self.floatingController.move(to: restoredPosition, animated: true)
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handlePresentation(notification:)),
            name: FloatingControllerPresentationManager.floatingControllerDidPresent,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleDismission(notification:)),
            name: FloatingControllerPresentationManager.floatingControllerDidDismiss,
            object: nil
        )
    }

    private func unregisterFromNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: FloatingControllerPresentationManager.floatingControllerDidPresent,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: FloatingControllerPresentationManager.floatingControllerDidDismiss,
            object: nil
        )
    }

    // MARK: - Enums

    private enum NotificationKey: String {
        case groupID
        case controllerID
        case shouldMinimizePreviousController
        case inset
    }

    enum GrabberAppearance {
        case dark
        case light

        var viewColor: UIColor {
            switch self {
            case .dark:
                return UIColor(red: 0.36, green: 0.35, blue: 0.35, alpha: 1.0)
            default:
                return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            }
        }
    }
}

extension FloatingControllerPresentationManager: FloatingPanelControllerDelegate {
    func floatingPanel(
        _ viewController: FloatingPanelController,
        layoutFor newCollection: UITraitCollection
    ) -> FloatingPanelLayout? {
        return CustomFloatingPanelLayout(manager: self)
    }

    func floatingPanelDidChangePosition(_ viewController: FloatingPanelController) {
        self.currentPosition = viewController.position

        switch viewController.position {
        case .hidden:
            NotificationCenter.default.post(
                name: FloatingControllerPresentationManager.floatingControllerDidDismiss,
                object: nil,
                userInfo: self.notificationUserInfo
            )
            self.unregisterFromNotifications()
        case .half where self.context.isRealFullPositionSupported:
            NotificationCenter.default.post(
                name: FloatingControllerPresentationManager.floatingControllerDidDismiss,
                object: nil,
                userInfo: self.notificationUserInfo
            )
            self.unregisterFromNotifications()
            // dismiss controller
            viewController.fp_dismiss(animated: true)
        case .half:
            // Scroll to the top if drag with anchor
            DispatchQueue.main.async { [weak self] in
                self?.floatingController.scrollView?.setContentOffset(.zero, animated: false)
            }
        default:
            break
        }
    }

    func floatingPanel(_ vc: FloatingPanelController, behaviorFor newCollection: UITraitCollection) -> (any FloatingPanelBehavior)? {
        CustomFloatingPanelBehavior()
    }
}

private class CustomFloatingPanelLayout: FloatingPanelLayout {
    private var manager: FloatingControllerPresentationManager?

    init(manager: FloatingControllerPresentationManager) {
        self.manager = manager
    }

    var bottomInteractionBuffer: CGFloat {
        guard let manager = self.manager else {
            fatalError("Presentation manager is detached")
        }

        return manager.context.insetForHalfPosition
    }

    var initialPosition: FloatingPanelPosition {
        guard let manager = self.manager else {
            fatalError("Presentation manager is detached")
        }

        return manager.context.initialPosition
    }

    var supportedPositions: Set<FloatingPanelPosition> {
        guard let manager = self.manager else {
            fatalError("Presentation manager is detached")
        }

        var positions: [FloatingPanelPosition] = manager.context.isHalfPositionSupported
            ? [.half]
            : []

        if manager.context.isFullPositionSupported {
            positions += [.full]
        }

        if manager.isMinimized {
            positions += [.tip]
        }

        return .init(positions)
    }

    func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        guard let manager = self.manager else {
            fatalError("Presentation manager is detached")
        }

        switch position {
        case .full,
             .half where manager.context.isRealFullPositionSupported:
            return nil
        case .half:
            return manager.context.insetForHalfPosition
        case .tip:
            return manager.minimizationInset
        default:
            return nil
        }
    }

    func backdropAlphaFor(position: FloatingPanelPosition) -> CGFloat {
        guard let manager = self.manager else {
            fatalError("Presentation manager is detached")
        }

        let value = FloatingControllerPresentationManager.Appearance.overlayAlpha
            / CGFloat(manager.modalStackPosition + 1)
        return value
    }
}

class CustomFloatingPanelBehavior: FloatingPanelBehavior {
    var removalProgress: CGFloat { 0.1 }
}

// MARK: - Notification.Name

extension FloatingControllerPresentationManager {
    static let floatingControllerDidPresent = Notification.Name("floatingControllerDidPresent")
    static let floatingControllerDidDismiss = Notification.Name("floatingControllerDidDismiss")
}
