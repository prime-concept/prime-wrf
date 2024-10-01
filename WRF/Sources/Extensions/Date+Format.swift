import Foundation

extension Date {
    func formatToBackend() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }

    func formatToShow() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func unformatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: self) {
            return date.formatToShow()
        }
        return ""
    }
}

extension Date {
	static var today: Date {
		Date().down(to: .day)
	}

	var asClosedRange: ClosedRange<Date> {
		self...self
	}

	var asRange: Range<Date> {
		self..<self
	}

	func isIn(same granularity: Calendar.Component, with date: Date) -> Bool {
		Calendar.current.isDate(self, equalTo: date, toGranularity: granularity)
	}

	func down(to granularity: Calendar.Component) -> Date {
		var components = Calendar.Component.roundableCases
		guard let index = components.firstIndex(of: granularity) else {
			fatalError("Only \(components) are permitted!")
		}

		components = Array(components.prefix(through: index))

		let dateComponents = Calendar.current.dateComponents(Set(components), from: self)
		let date = Calendar.current.date(from: dateComponents) ?? self

		return date
	}

	func with(_ component: Calendar.Component, _ value: Int) -> Date? {
		Calendar.current.date(bySetting: component, value: value, of: self)
	}

	func formatted(_ format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format

		let result = formatter.string(from: self)
		return result
	}

	subscript (_ component: Calendar.Component) -> Int {
		Calendar.current.component(component, from: self)
	}
}

extension String {
	func date(_ format: String, _ timeZoneString: String = "Europe/Moscow") -> Date? {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.timeZone = TimeZone(identifier: timeZoneString) ?? TimeZone(abbreviation: timeZoneString)
		return formatter.date(from: self)
	}
}

extension Date {
	func string(_ format: String, _ timeZoneString: String = "Europe/Moscow") -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		
		formatter.timeZone = TimeZone(identifier: timeZoneString) ?? TimeZone(abbreviation: timeZoneString)
		
		return formatter.string(from: self)
	}
}

extension ClosedRange where Bound == Date {
	func iterate(by component: Calendar.Component, _ value: Int = 1, _ iterator: (Date) -> Void) {
		var date = self.lowerBound
		while date <= self.upperBound {
			iterator(date)
			guard let newDate = Calendar.current.date(byAdding: component, value: value, to: date) else {
				break
			}
			date = newDate
		}
	}

	func down(to granularity: Calendar.Component) -> Self {
		self.lowerBound.down(to: granularity)...self.upperBound.down(to: granularity)
	}

	static var today: Self {
		Date().down(to: .day).asClosedRange
	}
}

extension Range where Bound == Date {
	func iterate(by component: Calendar.Component, _ value: Int = 1, _ iterator: (Date) -> Void) {
		var date = self.lowerBound
		while date < self.upperBound {
			iterator(date)
			guard let newDate = Calendar.current.date(byAdding: component, value: value, to: date) else {
				break
			}
			date = newDate
		}
	}

	func down(to granularity: Calendar.Component) -> Self {
		self.lowerBound.down(to: granularity)..<self.upperBound.down(to: granularity)
	}

	static var today: Self {
		Date().down(to: .day).asRange
	}
}

extension Array where Element == Date {
	var asRange: ClosedRange<Date> {
		let sorted = self.sorted(by: <)
		return sorted[0]...sorted[sorted.count - 1]
	}
}

extension Calendar.Component: CaseIterable {
	public static var allCases: [Calendar.Component] = [
			.weekday,
			.weekdayOrdinal,
			.quarter,
			.weekOfMonth,
			.weekOfYear,
			.yearForWeekOfYear,
			.calendar,
			.timeZone,
			.era,
			.year,
			.month,
			.day,
			.hour,
			.minute,
			.second,
			.nanosecond
	]

	public static var roundableCases: [Self] {
		[
			.year,
			.month,
			.day,
			.hour,
			.minute,
			.second,
			.nanosecond
		]
	}
}

extension Int {
	var seconds: DateComponents {
		DateComponents(second: self)
	}

	var minutes: DateComponents {
		DateComponents(minute: self)
	}

	var hours: DateComponents {
		DateComponents(hour: self)
	}

	var days: DateComponents {
		DateComponents(day: self)
	}

	var months: DateComponents {
		DateComponents(month: self)
	}
	
	var years: DateComponents {
		DateComponents(year: self)
	}
}

extension Date {
	var seconds: DateComponents {
		self[.second].seconds
	}

	var minutes: DateComponents {
		self[.minute].minutes
	}

	var hours: DateComponents {
		self[.hour].hours
	}

	var days: DateComponents {
		self[.day].days
	}

	var months: DateComponents {
		self[.month].months
	}

	var years: DateComponents {
		self[.year].years
	}
}

public func +(lhs: Date, rhs: DateComponents) -> Date {
	Calendar.current.date(byAdding: rhs, to: lhs)!
}

