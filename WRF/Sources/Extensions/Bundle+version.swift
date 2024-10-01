import Foundation

extension Bundle {
    var bundleVersion: String {
        // swiftlint:disable force_unwrapping
        // swiftlint:disable force_cast
        self.infoDictionary!["CFBundleVersion"] as! String
    }

	public static var isTestFlightOrSimulator: Bool {
#if targetEnvironment(simulator)
		return true
#else
		let lastPath = Bundle.main.appStoreReceiptURL?.lastPathComponent
		guard let lastPath = lastPath else {
			return true
		}

		return lastPath == "sandboxReceipt"
#endif
	}
}
