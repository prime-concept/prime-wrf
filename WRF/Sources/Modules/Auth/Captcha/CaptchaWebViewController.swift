import UIKit
import WebKit

class CaptchaWebViewController: GenericWebViewController {
	private let host: String
	private let secret: String

	var successHandler: ((String) -> Void)?
	var errorHandler: ((Error) -> Void)?

    init(host: String, secret: String, showLoader: Bool = true, preferredHeight: CGFloat? = nil) {
		self.host = host
		self.secret = secret

		let url = URL(string: "\(host)?sitekey=\(secret)")!

		super.init(url: url, showLoader: showLoader, preferredHeight: preferredHeight)
	}

	private lazy var userContentController: WKUserContentController = {
		let validationHost = self.host.replacing(regex: "webview$", with: "validate")

		let handler = CaptchaWebContentHandler()
		handler.delegate = self

		let controller = WKUserContentController()
		controller.add(handler, name: "NativeClient")
		return controller
	}()

	override func getConfiguration() -> WKWebViewConfiguration {
		let configuration = super.getConfiguration()
		configuration.userContentController = self.userContentController
		return configuration
	}

	override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		super.webView(webView, didFinish: navigation)
		self.calculateHeight()
	}

	override func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		super.webView(webView, didFail: navigation, withError: error)
		self.calculateHeight()
	}

	private func calculateHeight() {
		self.webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
			if complete == nil {
				return
			}
			self.webView.evaluateJavaScript("document.documentElement.scrollHeight") { (height, error) in
				print("CAPTCHA HEIGHT: \(String(describing: height))")
			}
		})
	}
}

extension CaptchaWebViewController: CaptchaHandlerDelegate {
	func onShow() { }

	func onHide() { }

	func onSuccess(_ token: String) {
		self.successHandler?(token)
	}

	func onError(_ error: Error) {
		self.errorHandler?(error)
	}
}
