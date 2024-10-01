import Foundation

struct PrimePassFeedbackRequest: Codable {
    let userID: PrimePassClient.IDType
    let restaurantID: PrimePassRestaurantIDType
    let review: String
    let assessment: Int
    let publish: Bool
    let improve: [String]

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case restaurantID = "place"
        case review
        case assessment
        case publish
        case improve
    }
}
