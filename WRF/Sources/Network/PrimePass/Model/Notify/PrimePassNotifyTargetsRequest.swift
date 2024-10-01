import Foundation

struct PrimePassNotifyTargetsRequest: Codable {
    let userID: PrimePassClient.IDType
    let destination: String
    let channel: Channel

    enum Channel: String, Codable {
        case firebase = "FIREBASE"
        case web = "WEB"
        case sms = "SMS"
        case email = "EMAIL"
    }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case destination
        case channel
    }
}
