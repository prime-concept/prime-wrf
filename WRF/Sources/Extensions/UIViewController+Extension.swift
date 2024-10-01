import UIKit

extension UIViewController {
	var topmostPresentedOrSelf: UIViewController {
		var result = self
		while let presented = result.presentedViewController {
			result = presented
		}
		return result
	}

	func present(animated: Bool = true, completion: (() -> Void)? = nil) {
		UIApplication.shared.keyWindow?
			.rootViewController?
			.topmostPresentedOrSelf
			.present(self, animated: animated)
	}
}
