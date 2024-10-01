import Foundation

struct PrimePassAppFeedbackRequest: Codable {
    let userID: Int
    let type: String
    let email: String
    let phone: String
    let review: String
    let images: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case type
        case email
        case phone
        case review
        case images = "photo"
    }
}
