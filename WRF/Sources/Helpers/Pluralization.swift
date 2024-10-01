import Foundation

extension String {
	func pluralized(_ count: Int) -> String {
		Pluralizer.pluralized(self, count)
	}

	func pluralized(_ format: String, _ count: Int, _ countFormatter: NumberFormatter? = nil) -> String {
		let value = Pluralizer.pluralized(self, count)
		var countString = count.description

		var result = format

		if let formatter = countFormatter {
			countString = formatter.string(from: count) ?? countString
		}

		result = result.replacingOccurrences(of: "%@", with: value)
		result = result.replacingOccurrences(of: "%d", with: countString)

		return result
	}
}

extension AppDelegate {
	func setupPluralization() {
		["ru", "en"].forEach {
			with(Pluralizer.pluralizer(for: $0)) { pluralizer in
				pluralizer.register(key: "баллов", .init(none: "баллов", one: "балл", few: "балла", many: "баллов", other: "балла"))
				pluralizer.register(key: "рублей", .init(none: "рублей", one: "рубль", few: "рубля", many: "рублей", other: "рубля"))
				pluralizer.register(key: "дней", .init(none: "дней", one: "день", few: "дня", many: "дней", other: "дня"))
                
                pluralizer.register(
                    key: "бонусных баллов", .init(
                        none: "бонусных баллов",
                        one: "бонусный балл", few: "бонусных балла",
                        many: "бонусных баллов",
                        other: "бонусных баллов"
                    )
                )
                
                pluralizer.register(
                    key: "балла сгорит", .init(
                        none: "баллов сгорит",
                        one: "балл сгорит",
                        few: "балла сгорит",
                        many: " баллов сгорит",
                        other: "балла сгорит"
                    )
                )
			}
		}
	}
}

extension String {
	var asIntOrZero: Int {
		let cleanValue = self.replacing(regex: "[^\\d]", with: "")
		let int = Int(cleanValue) ?? 0

		return int
	}
}

extension Optional where Wrapped == String {
	var asIntOrZero: Int {
		(self ?? "").asIntOrZero
	}
}

fileprivate final class Pluralizer {
	struct Pluralization {
		init(none: String, one: String, few: String, many: String, other: String) {
			self.none = none
			self.one = one
			self.few = few
			self.many = many
			self.other = other
		}

		// English
		init(one: String, other: String) {
			self.none = other
			self.one = one
			self.few = other
			self.many = other
			self.other = other
		}

		let none: String
		let one: String
		let few: String
		let many: String
		let other: String

		fileprivate func value(for count: Int, of key: String) -> String {
			if count == 0 {
				return self.none
			}

			if count % 10 == 1 && count % 100 != 11 {
				return self.one
			}

			if (count % 10 >= 2 && count % 10 <= 4) && !(count % 100 >= 12 && count % 100 <= 14) {
				return self.few
			}

			if (count % 10 == 0)
				|| (count % 10 >= 5 && count % 10 <= 9)
				|| (count % 100 >= 11 && count % 100 <= 14) {

				return self.many
			}

			return self.other
		}
	}

	private static var pluralizers = [String: Pluralizer]()
	private var data = [String: Pluralization]()

	fileprivate static func pluralizer(for localeCode: String) -> Pluralizer {
		let name = localeCode.lowercased()

		if let pluralizer = Self.pluralizers[name] {
			return pluralizer
		}

		let pluralizer = Pluralizer()
		Self.pluralizers[name] = pluralizer

		return pluralizer
	}

	fileprivate static func pluralized(_ key: String, _ count: Int) -> String {
		var lang = Locale.current.languageCode
		lang = lang == "ru" ? lang : "en"

		guard let pluralization = Self.pluralizer(for: lang!).data[key] else {
			return key
		}

		return pluralization.value(for: count, of: key)
	}

	fileprivate func register(key: String, _ pluralization: Pluralization) {
		self.data[key] = pluralization
	}
}
