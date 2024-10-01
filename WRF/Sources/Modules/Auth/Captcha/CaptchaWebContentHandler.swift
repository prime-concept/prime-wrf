import WebKit

protocol CaptchaHandlerDelegate: AnyObject {
	func onShow()
	func onHide()

	func onSuccess(_ token: String)
	func onError(_ error: Error)
}

final class CaptchaWebContentHandler: NSObject, WKScriptMessageHandler {
	private enum Methods: String {
		case captchaDidFinish
		case challengeDidAppear
		case challengeDidDisappear
	}

	weak var delegate: CaptchaHandlerDelegate?

	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard let jsData = message.body as? [String: String] else { return }
		guard let methodName = jsData["method"] else { return }
		execMethod(name: methodName, params: jsData["data"])
	}

	func execMethod(name: String, params: Any?...) {
		guard let method = Methods(rawValue: name) else { return }
		switch method {
			case .captchaDidFinish:
				guard let token = params.first as? String else { return }
				onSuccess(token: token)
			case .challengeDidDisappear:
				onChallengeHide()
			case .challengeDidAppear:
				onChallengeVisible()
		}
	}

	private func onSuccess(token: String) {
		delegate?.onSuccess(token)
	}

	private func onChallengeVisible() {
		delegate?.onShow()
	}

	private func onChallengeHide() {
		delegate?.onHide()
	}
}
