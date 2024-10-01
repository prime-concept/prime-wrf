import Foundation

/// Модель данных ответа на запрос о расписании списка ресторанов
struct HostessListSchedule: Codable {

    let restaurantID: Int

    let key: String

    let restaurantName: String

    let restaurantPhone: String?

    let restaurantCity: String

    let restaurantTimezone: String

    let ruleName: String

    let timeData: [String]

    enum CodingKeys: String, CodingKey {
        case key
        case restaurantID = "restaurant_id"
        case restaurantName = "restaurant_name"
        case restaurantPhone = "restaurant_phone"
        case restaurantCity = "restaurant_city"
        case restaurantTimezone = "restaurant_timezone"
        case ruleName = "rule_name"
        case timeData = "schedule"
    }

	func eligibleTimeData(for date: Date = Date()) -> [String] {
		let nearestEligibleTime = date + 30.minutes

		let eligibleTimeData: [String] = self.timeData.compactMap { timeString in
			guard let date = timeString.date("YYYY-MM-dd'T'HH:mm:ssZ") else {
				return timeString
			}

			if date >= nearestEligibleTime {
				return date.string("HH:mm")
			}

			return nil
		}

		return eligibleTimeData
	}
}
