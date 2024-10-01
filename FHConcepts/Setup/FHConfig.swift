import PrimeGuideCore

struct FHConfig: ConfigProtocol
{

    // MARK: Constants
    
    private static let prodUDKey = "IS_PROD_ENABLED"
    private static let alertsUDKey = "ARE_DEBUG_ALERTS_ENABLED"
    
    // MARK: Instance Properties
    
    private let storage: UserDefaults
    
    // MARK: Initialization
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
 
        let isProd = Self.boolValue(from: storage, forKey: Self.prodUDKey, fallback: true)
        let isStaging = !isProd
        primePassBasePath = Self.primePassBasePath(staging: isStaging)
        primePassHostessBasePath = Self.primePassHostessBasePath(staging: isStaging)
        primePassHostessHeaderKey = Self.primePassHostessHeaderKey(staging: isStaging)
        navigatorBasePath = Self.navigatorBasePath(staging: isStaging)
    }
    
    private static func primePassBasePath(staging: Bool) -> String {
        if staging {
            "https://crm-dev.primepass.ru/api"
        } else {
            "https://crm-dev.primepass.ru/api/v1" // демо но для FH. crmAppToken ade6ebe3-661c-4096-9a34-b55254e4c9a3
        }
    }
    
    private static func primePassHostessBasePath(staging: Bool) -> String {
        if staging {
            "https://wrf-dev.hostes.me/api/internal/v2"
        } else {
            "https://demo.hostes.me/api/" // демо но для FH. возможно надо добавить /v2
        }
    }
    
    private static func primePassHostessHeaderKey(staging: Bool) -> String {
        if staging {
            "e6c863f7-983a-47fe-a09f-1f4c93373d4e"
        } else {
            "da84ed42-c098-41f2-a509-a1ec74912707"
        }
    }
    
    private static func navigatorBasePath(staging: Bool) -> String {
        if staging {
            "https://dellos-stage.navigator.technolab.com.ru/v1"
        } else {
            "https://dubai-stage.navigator.technolab.com.ru/v1" // демо но для FH.
        }
    }
    
    private static func boolValue(from storage: UserDefaults, forKey key: String, fallback: Bool) -> Bool {
        guard storage.object(forKey: key) != nil else { return fallback }
        return storage.bool(forKey: key)
    }
    
    // MARK: - ConfigProtocol
    
    let isDebugEnabled = Bundle.isTestFlightOrSimulator
    
    var isProdEnabled: Bool {
        get {
            Self.boolValue(from: storage, forKey: Self.prodUDKey, fallback: true)
        } set {
            storage.set(newValue, forKey: Self.prodUDKey)
        }
    }
    
    var areDebugAlertsEnabled: Bool {
        get {
            Self.boolValue(from: storage, forKey: Self.alertsUDKey, fallback: false)
        } set {
            storage.set(newValue, forKey: Self.alertsUDKey)
        }
    }
    
    let googleMapsKey = "AIzaSyARQ68zIAyetjD8KFvucyoU7r7T9Xrp3x0"
    let appMetricaKey = "c86956a0-3d72-4048-b512-6e03c4f88c09"
    let primePassHeaderKey = "16"
    let primePassBasePath: String
    let primePassHostessBasePath: String
    let primePassHostessHeaderKey: String
    let navigatorAppToken = "469d5840-f690-40e4-b13e-6b35ecea6f3a"
    let navigatorBasePath: String
    let youtubeAPIKey = "AIzaSyARQ68zIAyetjD8KFvucyoU7r7T9Xrp3x0"
    let cancelationRulesURL = URL(string: "https://101gourmet.me/maison_dellos_booking_rules")!
    let termsOfUseURL = URL(string: "https://101gourmet.me/maison_dellos_user_agreement")!
    let privacyPolicyURL = URL(string: "https://101gourmet.me/maison_dellos_privacy_policy")!
    let loyaltyRulesURL = URL(string: "https://101gourmet.me/maison_dellos_loyalty_rules")!
    let forPartnersURL = "https://admin.101.login.ru/"
    let deliveryBasePath = "https://wrf.101-gourmet.com"
    let deliveryCacheRecordName = "login.ru"
    let webFrameEmbedded = "wrf-ios" // TODO: Check this value
    let chatBaseURL = URL(string: "https://chat.primeconcept.co.uk/chat-server/v3")!
    let chatStorageURL = URL(string: "https://chat.primeconcept.co.uk/storage")!
    let chatClientAppID = "wrfiOS" // TODO: Check this value
    
}
