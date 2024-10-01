import UIKit
import WebKit

class GenericWebViewController: UIViewController, UIScrollViewDelegate {
	private(set) var url: URL
	private let showLoader: Bool
    private let preferredHeight: CGFloat?

	private(set) lazy var webView = WKWebView(
		frame: UIScreen.main.bounds,
		configuration: self.getConfiguration()
	)

	init(url: URL, showLoader: Bool = false, preferredHeight: CGFloat? = nil) {
		self.url = url
		self.showLoader = showLoader
        self.preferredHeight = preferredHeight
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = self.webView

		self.webView.backgroundColor = .white
		self.webView.allowsBackForwardNavigationGestures = true
		self.webView.navigationDelegate = self
		self.webView.scrollView.delegate = self
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
        if let preferredHeight {
            webView.snp.makeConstraints { make in
                make.height.equalTo(480 - 20 - 44)
            }
        }

		webView.load(URLRequest(url: self.url))
		delay(0.3) {
			if self.showLoader {
				self.showSimplestLoader()
			}
		}
	}

	func getConfiguration() -> WKWebViewConfiguration {
		let configuration = WKWebViewConfiguration()
		configuration.suppressesIncrementalRendering  = true

		let preferences = WKPreferences()
		preferences.javaScriptEnabled = true
		configuration.preferences = preferences

		return configuration
	}
}

extension GenericWebViewController: WKNavigationDelegate {
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		if self.showLoader {
			self.hideSimplestLoader()
		}
	}

	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
		if self.showLoader {
			self.hideSimplestLoader()
		}
	}
}

extension UIView {
	func showSimplestLoader() {
		let loader = UIActivityIndicatorView()
		loader.tag = 324051509
		self.addSubview(loader)
		loader.make(.center, .equalToSuperview)

		loader.startAnimating()
	}

	func hideSimplestLoader() {
		self.subviews
			.first{ $0.tag == 324051509 && $0 is UIActivityIndicatorView }?
			.removeFromSuperview()
	}
}

extension UIViewController {
	func showSimplestLoader() {
		self.view.showSimplestLoader()
	}

	func hideSimplestLoader() {
		self.view.hideSimplestLoader()
	}
}
