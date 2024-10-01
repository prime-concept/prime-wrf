import PrimeGuideCore

struct WRFConfig: ConfigProtocol {
    
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
    
    let googleMapsKey = "AIzaSyBXdbqz-fUmShyGjTqIcQ8HunB1SeXGWEI"
    let appMetricaKey = "641f853d-133e-42b3-be90-201550d83c0e"
    let primePassHeaderKey = "2"
    let primePassBasePath: String
    let primePassHostessBasePath: String
    let primePassHostessHeaderKey: String
    let navigatorAppToken = "3e0c81ea-ab14-4b83-b0b5-c9ccee925706"
    let navigatorBasePath: String
    let youtubeAPIKey = "AIzaSyDLd_yIM152Op3xHJXUDLU3YiuZHsW6Nvo"
    let cancelationRulesURL = URL(string: "https://101gourmet.me/booking_rules.pdf")!
    let termsOfUseURL = URL(string: "https://101gourmet.me/user_agreement.pdf")!
    let privacyPolicyURL = URL(string: "https://101gourmet.me/privacy_policy.pdf")!
    let loyaltyRulesURL = URL(string: "https://101gourmet.me/loyalty_rules.pdf")!
    let forPartnersURL = "https://admin.101.login.ru/"
    let deliveryBasePath = "https://wrf.101-gourmet.com"
    let deliveryCacheRecordName = "login.ru"
    let webFrameEmbedded = "wrf-ios"
    let chatBaseURL = URL(string: "https://chat.primeconcept.co.uk/chat-server/v3")!
    let chatStorageURL = URL(string: "https://chat.primeconcept.co.uk/storage")!
    let chatClientAppID = "wrfiOS"
    
    private let storage: UserDefaults
    private static let prodUDKey = "IS_PROD_ENABLED"
    private static let alertsUDKey = "ARE_DEBUG_ALERTS_ENABLED"
    
    init(storage: UserDefaults = .standard) {
        self.storage = storage
        let isProd = Self.boolValue(from: storage, forKey: Self.prodUDKey, fallback: true)
        let isStaging = !isProd
        primePassBasePath = Self.primePassBasePath(staging: isStaging)
        primePassHostessBasePath = Self.primePassHostessBasePath(staging: isStaging)
        primePassHostessHeaderKey = Self.primePassHostessHeaderKey(staging: isStaging)
        navigatorBasePath = Self.navigatorBasePath(staging: isStaging)
    }
    
    private static func boolValue(from storage: UserDefaults, forKey key: String, fallback: Bool) -> Bool {
        guard storage.object(forKey: key) != nil else { return fallback }
        return storage.bool(forKey: key)
    }
    
    private static func primePassBasePath(staging: Bool) -> String {
        if staging {
            "https://crm-dev.primepass.ru/api"
        } else {
            "https://crm.primepass.ru/api"
        }
    }
    
    private static func primePassHostessBasePath(staging: Bool) -> String {
        if staging {
            "https://wrf-dev.hostes.me/api/v2"
        } else {
            "https://wrf.hostes.me/api/v2"
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
            "https://wrf-stage.navigator.technolab.com.ru/v1"
        } else {
            "https://wrf.technolab.com.ru/v1"
        }
    }
    
}

