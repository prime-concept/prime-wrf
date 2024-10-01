import Foundation

// swiftlint:disable discouraged_optional_boolean
struct PrimePassCard: Codable {
    let userID: PrimePassClient.IDType
    let balance: Int
    let subscribed: Bool?
    let deleted: Bool?
    let gradeName: String
    let ticketGradeID: Int?
    let ticketGradeName: String?
    let cardNumber: String
    let nextGradeUpgradeAmount: Int?
    let courseBonus: Int
    let courseRub: Int
    let bonusBalance: Int

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case balance
        case subscribed = "subscription"
        case deleted
        case gradeName = "grade_name"
        case ticketGradeID = "tickets_grade_id"
        case ticketGradeName = "tickets_grade_name"
        case cardNumber = "num_discount_card"
        case nextGradeUpgradeAmount = "to_next_grade"
        case courseBonus = "course_bonus"
        case courseRub = "course_rub"
        case bonusBalance = "bonus_balance"
    }
}
