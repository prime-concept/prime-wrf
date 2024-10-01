import Foundation

// swiftlint:disable force_unwrapping
enum Config {
	/**
	 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥
	 💥 SET TO FALSE TO DISABLE DEBUG MODE + LOGS IN PRODUCTION BUILDS 💥
	 💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥💥
	 */

	static var isDebugEnabled = Bundle.isTestFlightOrSimulator

	static let storage = UserDefaults.standard

	private static let logUDKey = "IS_LOG_ENABLED"
	private static let debugUDKey = "IS_DEBUG_ENABLED"
	private static let prodUDKey = "IS_PROD_ENABLED"
	private static let alertsUDKey = "ARE_DEBUG_ALERTS_ENABLED"
	private static let verboseLogUDKey = "IS_VERBOSE_LOG_ENABLED"

	static var isLogEnabled: Bool {
		get { self.bool(for: logUDKey, or: isDebugEnabled)}
		set { storage.setValue(newValue, forKey: debugUDKey) }
	}

	static var isProdEnabled: Bool {
		get { self.bool(for: prodUDKey, or: true) }
        set {
            storage.set(newValue, forKey: prodUDKey)
            storage.synchronize()
        }
	}

	static var areDebugAlertsEnabled: Bool {
		get { self.bool(for: alertsUDKey) }
		set { storage.set(newValue, forKey: alertsUDKey) }
	}

	static var isVerboseLogEnabled: Bool {
		get { self.bool(for: verboseLogUDKey) }
		set { storage.set(newValue, forKey: verboseLogUDKey) }
	}

	static func bool(for key: String, or defaultValue: Bool = false) -> Bool {
		let value: Bool? = storage.value(forKey: key) as? Bool
		return value ?? defaultValue
	}

	static func resolve<T>(prod: T, stage: T) -> T {
		isProdEnabled ? prod : stage
	}
}
