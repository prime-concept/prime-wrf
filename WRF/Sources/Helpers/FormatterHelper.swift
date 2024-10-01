import CoreLocation
import Foundation

enum FormatterHelper {
    /// Shared date formatter with correct locale
    static func makeCorrectLocaleDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }

    /// Shared calendar with correct locale
    static func makeCorrectLocaleCalendar() -> Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ru_RU")
        return calendar
    }

    /// Format floating point `number` with `precision` decimal points;
    /// - Sample: number = 0.123456, precision = 2 -> "0.12"
    static func floatRepresentation(_ number: Float, precision: Int) -> String {
        return String(format: "%.\(precision)f", number)
    }

    /// Format distance in meters;
    /// - Sample: distanceInMeters = 100500 => "100.5 км"
    static func distanceRepresentation(distanceInMeters: CLLocationDistance) -> String {
        if distanceInMeters < 1000 {
            return "\(Int(distanceInMeters)) м"
        }

        return "\(FormatterHelper.floatRepresentation(Float(distanceInMeters / 1000), precision: 1)) км"
    }

    /// Format assessments count with correct plural form;
    static func assessments(_ count: Int) -> String {
        return "\(count) \(Localization.pluralForm(number: count, forms: ["оценка", "оценки", "оценок"]))"
    }
}
