import CoreLocation
import SnapKit
import UIKit
import WebKit

enum WebFrameData {
    case restaurant(id: String)
    case deliveries
    case userAgreement
    case forPartners

    func url(authorizationData: AuthorizationData?, location: CLLocation?) -> URL? {
        var params: [(String, String)] = []
        if let token = authorizationData?.token, let userID = authorizationData?.userID {
            params += [("wrf_token", "\(token)"), ("user_id", "\(userID)")]
        }

        if let location = location {
            params += [("lat", "\(location.coordinate.latitude)"), ("lng", "\(location.coordinate.longitude)")]
        }

        params += [("embedded", PGCMain.shared.config.webFrameEmbedded)]

        var paramsString = params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
        if !paramsString.isEmpty {
            paramsString = "?" + paramsString
        }

        switch self {
        case .restaurant(let id):
            return URL(string: "\(PGCMain.shared.config.deliveryBasePath)/restaurant/\(id)\(paramsString)")
        case .deliveries:
            return URL(string: "\(PGCMain.shared.config.deliveryBasePath)/delivery\(paramsString)")
        case .userAgreement:
            return PGCMain.shared.config.termsOfUseURL
        case .forPartners:
            return URL(string: "\(PGCMain.shared.config.forPartnersURL)\(paramsString)")
        }
    }
}

final class WebFrameViewController: UIViewController, WKHTTPCookieStoreObserver, BlockingLoaderPresentable {
    private let frameData: WebFrameData
    private let authService: AuthServiceProtocol
    private let locationService: LocationServiceProtocol

    private var webViewURLObserver: NSKeyValueObservation?

    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.allowsBackForwardNavigationGestures = false
        view.allowsLinkPreview = false
        view.navigationDelegate = self
        return view
    }()

    private var timer: Timer?

    init(frameData: WebFrameData, authService: AuthServiceProtocol, locationService: LocationServiceProtocol) {
        self.frameData = frameData
        self.authService = authService
        self.locationService = locationService

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.timer?.invalidate()
        self.timer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()

        let optionalURL = self.frameData.url(
            authorizationData: self.authService.authorizationData,
            location: self.locationService.lastLocation
        )

        guard let url = optionalURL, url.absoluteString.contains("://") else {
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true

        let storage = HTTPCookieStorage.shared
        let cookies = storage.cookies(for: url) ?? []

        let headers = HTTPCookie.requestHeaderFields(with: cookies)
        for (name, value) in headers {
            request.addValue(value, forHTTPHeaderField: name)
        }

        self.webViewURLObserver = self.webView.observe(\.url, options: .new) { [weak self] _, change in
            guard let strongSelf = self else {
                return
            }

            guard let optionalURL = change.newValue, let url = optionalURL else {
                return
            }

            if let appScheme = Bundle.main.urlScheme(), url.absoluteString.starts(with: appScheme) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }

            if case WebFrameData.forPartners = strongSelf.frameData {
                return
            }

            if url.relativePath == "/" {
                WebCacheCleaner.cleanDeliveryCache()
                strongSelf.dismiss(animated: true, completion: nil)
            }
        }

        print("delivery frame: present with url = \(url.absoluteString)")

        self.webView.load(request)
        self.showLoading()

        //TODO: need to move in background thread
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if #available(iOS 11, *) {
                let dataStore = WKWebsiteDataStore.default()
                dataStore.httpCookieStore.getAllCookies { cookies in
                    var newCookies = [HTTPCookie]()
                    cookies.forEach { cookie in
                        var properties: [HTTPCookiePropertyKey: Any] = [:]
                        properties[.domain] = cookie.domain
                        properties[.expires] = Date().addingTimeInterval(60 * 60 * 24 * 365)
                        properties[.name] = cookie.name
                        properties[.path] = cookie.path
                        properties[.value] = cookie.value
                        properties[.version] = cookie.version
                        properties[.secure] = cookie.isSecure
                        if let newCookie = HTTPCookie(properties: properties) {
                            newCookies.append(newCookie)
                        }
                    }
                    HTTPCookieStorage.shared.setCookies(
                        newCookies.isEmpty ? cookies : newCookies,
                        for: url,
                        mainDocumentURL: nil
                    )
                }
            } else {
                guard let cookies = HTTPCookieStorage.shared.cookies else {
                    return
                }
                print(cookies)
            }
        }
    }

    // MARK: - Private

    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.webView)

        self.webView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
    }
}

extension WebFrameViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        decisionHandler(.allow)
    }

    //swiftlint:disable:next implicitly_unwrapped_optional
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoading()
    }
}

private extension Bundle {
    func urlScheme() -> String? {
        guard let urlTypes = self.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
              let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
              let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
              let scheme = urlSchemes.first as? String else {
            return nil
        }

        return scheme
    }
}

private final class WebCacheCleaner {
    class func cleanDeliveryCache() {
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                if record.displayName == PGCMain.shared.config.deliveryCacheRecordName {
                    WKWebsiteDataStore.default().removeData(
                        ofTypes: record.dataTypes,
                        for: [record],
                        completionHandler: {}
                    )
                }
            }
        }
    }
}
