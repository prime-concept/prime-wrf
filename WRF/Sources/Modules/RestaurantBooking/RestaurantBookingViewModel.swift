import Foundation

struct RestaurantBookingViewModel {
    let schedule: Schedule

    let today: DayDescription
    let tomorrow: DayDescription

    struct DayDescription {
        let shortDayOfWeek: String
        let date: Date
        let dayNumber: String
        let dayDescription: String
        let isSelected: Bool
    }

    enum Schedule {
        case loading
        case result([String])
    }
}
