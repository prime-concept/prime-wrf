import UIKit

class WRFWindow: UIWindow {
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			self.presentDebugMenuIfNeeded()
		}
	}

	private func presentDebugMenuIfNeeded() {
		guard PGCMain.shared.config.isDebugEnabled else {
			return
		}

		guard let topVC = self.rootViewController?.topmostPresentedOrSelf else {
			return
		}

		if topVC is DebugMenuViewController {
			return
		}

		let debugMenu = DebugMenuViewController()
		topVC.present(debugMenu, animated: true, completion: nil)
	}
}
