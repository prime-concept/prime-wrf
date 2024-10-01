import Foundation

extension String {
    func isValidEmail() -> Bool {
        let firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstpart + "@" + serverpart + "[A-Za-z]{2,8}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailPredicate.evaluate(with: self)
    }
}

extension String {
	func replacing(regex: String, with replacement: String) -> String {
		self.replacingOccurrences(of: regex, with: replacement, options: .regularExpression)
	}

	func stripping(regex: String) -> String {
		self.replacingOccurrences(of: regex, with: "", options: .regularExpression)
	}

	func first(match regex: String) -> String? {
		if let range = self.range(of: regex, options: .regularExpression) {
			return String(self.prefix(upTo: range.upperBound).suffix(from: range.lowerBound))
		}

		return nil
	}
}

extension String {
	subscript (i: Int) -> String {
		return self[i ..< i + 1]
	}

	func substring(fromIndex: Int) -> String {
		return self[min(fromIndex, count) ..< count]
	}

	func substring(toIndex: Int) -> String {
		return self[0 ..< max(0, toIndex)]
	}

	subscript (r: Range<Int>) -> String {
		let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
											upper: min(count, max(0, r.upperBound))))
		let start = index(startIndex, offsetBy: range.lowerBound)
		let end = index(start, offsetBy: range.upperBound - range.lowerBound)
		return String(self[start ..< end])
	}
}
