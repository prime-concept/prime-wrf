struct BonusesModelResponse: Codable {
    let data: BonusesModel
}

struct BonusesModel: Codable {
    let balance: Int
    let expiredBonuses: [ExpiredBonuses]

    enum CodingKeys: String, CodingKey {
        case balance = "bonus_balance"
        case expiredBonuses = "expired_bonuses"
    }
}

struct ExpiredBonuses: Codable {
    let estimateDebit: Int
    let expiredAt: Date

    enum DateParsingError: Error {
        case invalidDateFormat
        // You can add other error cases related to date parsing here
    }

    enum CodingKeys: String, CodingKey {
        case estimateDebit = "estimate_debit"
        case expiredAt = "expired_at"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CodingKeys.self)

        estimateDebit = try dataContainer.decode(Int.self, forKey: .estimateDebit)
        let dateString = try dataContainer.decode(String.self, forKey: .expiredAt)

        guard let date = Self.dateFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .expiredAt,
                in: dataContainer,
                debugDescription: "date string does not match format expected by formatter")
        }

        expiredAt = date
    }

}
