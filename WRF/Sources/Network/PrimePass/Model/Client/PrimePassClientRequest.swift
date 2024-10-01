import Foundation

struct PrimePassClientCreateRequest: Codable {
    let name: String
    let surname: String
    let phone: String
	let email: String
    let authorizationType: PrimePassAuthorizationType
    let issueCard: Bool
    let birthday: String
    let gender: Gender?
	let captchaToken: String?
	let deviceId: String?

    enum CodingKeys: String, CodingKey {
        case name
        case surname
        case phone
        case birthday
        case authorizationType = "type_authorization"
        case issueCard = "issue_card"
        case gender
		case email
		case captchaToken = "captcha_token"
		case deviceId = "device_id"
    }
}

enum PrimePassAuthorizationType: String, Codable {
    case phone = "PHONE"
}
