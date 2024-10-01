import Foundation

// swiftlint:disable force_unwrapping
extension Config {
	static let primePassBasePath = resolve(
		prod: "https://crm.primepass.ru/api",
		stage: "https://crm-dev.primepass.ru/api"
	)

	static let primePassHostessBasePath = resolve(
		prod: "https://wrf.hostes.me/api",
		stage: "https://wrf-dev.hostes.me/api"
	)

	static let primePassHostessHeaderKey = resolve(
		prod: "da84ed42-c098-41f2-a509-a1ec74912707",
		stage: "e6c863f7-983a-47fe-a09f-1f4c93373d4e"
	)

	static let primePassHeaderKey = "5"

	static let googleMapsKey = "AIzaSyBrq7suBHwNq9njtYR4IQOO7KeeXdQfX5E"
	static let appMetricaKey = "7ef1d756-09b7-471f-8d14-561f5db273da"

    static let navigatorAppToken = "95680aa2-a1af-4bc1-b925-c62014afb5d8"
    static let navigatorBasePath = "https://prime101.technolab.com.ru/v1"

    static let youtubeAPIKey = "AIzaSyAPgZ9LGhabU2A0vBoXs1sitiON06oK2Kw"

    static let cancelationRulesURL = URL(string: "https://digtl.tech/booking_rules.pdf")!
    static let termsOfUseURL = URL(string: "https://101.login.ru/offer")!
    static let privacyPolicyURL = URL(string: "digtl.tech/101/privacy_policy.docx")!
    static let loyaltyRulesURL = URL(string: "https://digtl.tech/loyalty_rules.pdf")!

    static let forPartnersURL = "https://admin.101.login.ru/"

    static let deliveryBasePath = "https://101-gourmet.com"
    static let deliveryCacheRecordName = "login.ru"
    static let webFrameEmbedded = "gourmet101-ios"

    static let chatBaseURL = URL(string: "https://chat.primeconcept.co.uk/chat-server/v3")!
    static let chatStorageURL = URL(string: "https://chat.primeconcept.co.uk/storage")!
    static let chatClientAppID = "gourmet101iOS"
}

