import Foundation

struct PrimePassReview: Codable {
    let userID: PrimePassClient.IDType?
    let place: PrimePassRestaurantIDType
    let review: String?
    let clientName: String?
    let clientSurname: String?
    let avatar: String?
    let publish: Bool
    let assessment: Int
    let timeKey: Date

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case place
        case review
        case clientName
        case clientSurname
        case avatar
        case publish
        case assessment
        case timeKey = "time_key"
    }
}
