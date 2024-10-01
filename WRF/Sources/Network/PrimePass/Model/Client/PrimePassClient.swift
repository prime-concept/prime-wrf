import Foundation

enum Gender: String, Codable, Equatable {
    case male = "M"
    case female = "F"

    var title: String {
        switch self {
        case .male:
            return "Мужской"
        case .female:
            return "Женский"
        }
    }
}

// swiftlint:disable discouraged_optional_boolean
struct PrimePassClient: Codable {
    typealias IDType = Int

    let userID: IDType
    let name: String?
    let surname: String?
    let phone: String
    let photo: String?
    let email: String?
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
    let birthday: String?
    let gender: Gender?

    var card: PrimePassCard {
        return PrimePassCard(
            userID: self.userID,
            balance: self.balance,
            subscribed: self.subscribed,
            deleted: self.deleted,
            gradeName: self.gradeName,
            ticketGradeID: self.ticketGradeID,
            ticketGradeName: self.ticketGradeName,
            cardNumber: self.cardNumber,
            nextGradeUpgradeAmount: self.nextGradeUpgradeAmount,
            courseBonus: self.courseBonus,
            courseRub: self.courseRub,
            bonusBalance: self.bonusBalance
        )
    }

    func copyWithUpdatingParameters(
        name: String,
        surname: String,
        phone: String,
        photo: String,
        email: String?,
        birthday: String?,
        gender: Gender?
    ) -> PrimePassClient {
        return PrimePassClient(
            userID: self.userID,
            name: name,
            surname: surname,
            phone: phone,
            photo: photo,
            email: email,
            balance: self.balance,
            subscribed: self.subscribed,
            deleted: self.deleted,
            gradeName: self.gradeName,
            ticketGradeID: self.ticketGradeID,
            ticketGradeName: self.ticketGradeName,
            cardNumber: self.cardNumber,
            nextGradeUpgradeAmount: self.nextGradeUpgradeAmount,
            courseBonus: self.courseBonus,
            courseRub: self.courseRub,
            bonusBalance: self.bonusBalance,
            birthday: birthday,
            gender: gender
        )
    }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case name
        case surname
        case phone
        case photo = "client_photo"
        case email
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
        case birthday
        case gender
    }
}
