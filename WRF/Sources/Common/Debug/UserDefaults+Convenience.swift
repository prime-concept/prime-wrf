import Foundation

extension UserDefaults {
	/// Returns the element at the specified index if it is within bounds, otherwise nil.
	static subscript(string key: String) -> String? {
		get {
			UserDefaults.standard.string(forKey: key)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: key)
		}
	}

	static subscript(bool key: String) -> Bool {
		get {
			UserDefaults.standard.bool(forKey: key)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: key)
		}
	}
}
