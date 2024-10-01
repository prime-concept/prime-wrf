import Foundation

struct PrimePassCodeRequest: Codable {
    let userID: Int
    let number: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case number
    }
}
