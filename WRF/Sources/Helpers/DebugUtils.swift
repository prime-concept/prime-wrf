import UIKit

class DebugUtils {
	static let shared = DebugUtils()
}

extension DebugUtils {
	func alert(
		title: String = "",
		message: String = "",
		clipTo length: Int = 280,
		showSettings: Bool = PGCMain.shared.config.isDebugEnabled,
		action: String,
		onAction: (()-> Void)? = nil)
	{
		onMain {
			var message = message
			let shouldAddEllipsis = message.count > length
			if shouldAddEllipsis {
				message = String(message.prefix(length))
			}

			let alert = UIAlertController(title: title,
										  message: message,
										  preferredStyle: .alert)
			alert.addAction(.init(title: action, style: .cancel) { _ in
				onAction?()
			})

			if showSettings {
				alert.addAction(.init(title: "🪲Настройки", style: .default) { _ in
					let debugMenu = DebugMenuViewController()
					debugMenu.present(animated: true)
				})
			}

			alert.present(animated: true)
		}
	}

	func alert(sender: AnyObject? = nil, _ items: Any..., separator: String = " ", terminator: String = "\n", clipTo length: Int = 280) {
		if PGCMain.shared.config.areDebugAlertsEnabled {
			let message = message(from: items, separator: separator)
			alert(message: message, clipTo: length, action: "OK", onAction: nil)
		}
		/* log(sender: sender, items, separator: separator, terminator: terminator) */
	}

	func message(from items: Any..., separator: String = " ") -> String {
		let message = items.deepMap{ $0 }.reduce("") {
			if let string = $1 as? String {
				return $0 + string + separator
			}
			return $0
		}
		return message
	}
}

extension Array {
	func skip(_ evaluation: (Element) -> Bool) -> [Element] {
		filter { !evaluation($0) }
	}

	func deepMap<T>(_ mapper: (Element) -> T) -> [T] {
		var result = [T]()
		self.forEach {
			if let subArray = $0 as? [Element] {
				result.append(contentsOf: subArray.deepMap(mapper))
			} else {
				result.append(mapper($0))
			}
		}
		return result
	}
}

extension Array where Element: Comparable {
	mutating func remove(element: Element) {
		self = self.filter { $0 != element}
	}
}
