import Foundation

// It will work if developer will only increase bundle version
final class AppVersionUpdateService {
    private static let bundleVersionKey = "bundleVersion"

    private let userDefaults: UserDefaults
    private let clientService: ClientServiceProtocol
    private let authService: AuthServiceProtocol

    init() {
        self.userDefaults = UserDefaults.standard
        self.clientService = ClientService.shared
        self.authService = AuthService()
    }

    func resetAuthIfNeeded() {
        guard let currentBundleVersion = Int(Bundle.main.bundleVersion) else {
            return
        }

        guard let lastBundleVersion = self.userDefaults.object(forKey: Self.bundleVersionKey) as? Int else {
            self.reset(with: currentBundleVersion)
            return
        }

        if lastBundleVersion == currentBundleVersion {
            return
        }

        self.reset(with: currentBundleVersion)
    }

    private func reset(with bundleVersion: Int) {
        self.authService.removeAuthorization()
        self.clientService.removeClient()

        self.userDefaults.set(bundleVersion, forKey: Self.bundleVersionKey)
    }
}

