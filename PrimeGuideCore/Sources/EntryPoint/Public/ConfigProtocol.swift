import Foundation

// TODO: Rename to `Config` when doing so won’t result in name collision
public protocol ConfigProtocol {
    var isDebugEnabled: Bool { get }
    var isProdEnabled: Bool { get set }
    var areDebugAlertsEnabled: Bool { get }
    var googleMapsKey: String { get }
    var appMetricaKey: String { get }
    var primePassHeaderKey: String { get }
    var primePassBasePath: String { get }
    var primePassHostessBasePath: String { get }
    var primePassHostessHeaderKey: String { get }
    var navigatorAppToken: String { get }
    var navigatorBasePath: String { get }
    var youtubeAPIKey: String { get }
    var cancelationRulesURL: URL { get }
    var termsOfUseURL: URL { get }
    var privacyPolicyURL: URL { get }
    var loyaltyRulesURL: URL { get }
    var forPartnersURL: String { get }
    var deliveryBasePath: String { get }
    var deliveryCacheRecordName: String { get }
    var webFrameEmbedded: String { get }
    var chatBaseURL: URL { get }
    var chatStorageURL: URL { get }
    var chatClientAppID: String { get }
}
