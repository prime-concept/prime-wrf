import Foundation

struct PrimePassLoyaltyRandomCodeResponse: Codable {
    let code: String?
    let expiredAt: Date?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case code
        case expiredAt = "expired_at"
        case createdAt = "created_at"
    }
}
