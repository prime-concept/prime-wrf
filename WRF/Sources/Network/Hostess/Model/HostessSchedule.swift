import Foundation

/// Модель данных ответа на запрос о расписании конкретного ресторана
struct HostessSchedule: Codable {

    struct Restaurant: Codable {
        let id: Int
    }

    struct Loading: Codable {
        let time: String
        let loadFactor: Double
    }

    let restaurant: Restaurant?
    let schedules: [Loading]


    var restaurantID: Int {
        self.restaurant?.id ?? Int.min
    }

    // Computed properties

    var timeData: [String] {
        self.schedules.filter { $0.loadFactor != 1 }.map { $0.time }
    }

    func eligibleTimeData(for date: Date = Date()) -> [String] {
        let nearestEligibleTime = date + 30.minutes

        let eligibleTimeData: [String] = self.timeData.compactMap { timeString in
            guard let date = timeString.date("YYYY-MM-dd'T'HH:mm:ss") else {
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
