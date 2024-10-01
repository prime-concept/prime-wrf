import Foundation

protocol DefaultsServiceProtocol: AnyObject {
    var isOnboardingShown: Bool { get set }
    var isPremium: Bool { get set }

    var isEmailEnabled: Bool { get set }
    var isNotificationEnabled: Bool { get set }
}

final class DefaultsService: DefaultsServiceProtocol {
    private let defaults = UserDefaults.standard

    private enum Key {
        static let isOnboardingShown = "isOnboardingShown"
        static let isPremium = "isPremium"
        static let isEmailEnabled = "isEmailEnabled"
        static let isNotificationEnabled = "isNotificationEnabled"
    }

    var isOnboardingShown: Bool {
        get {
            return self.defaults.bool(forKey: Key.isOnboardingShown)
        }
        set {
            self.defaults.set(newValue, forKey: Key.isOnboardingShown)
        }
    }

    var isPremium: Bool {
        get {
            return self.defaults.bool(forKey: Key.isPremium)
        }
        set {
            self.defaults.set(newValue, forKey: Key.isPremium)
        }
    }

    var isEmailEnabled: Bool {
        get {
            return self.defaults.bool(forKey: Key.isEmailEnabled)
        }
        set {
            self.defaults.set(newValue, forKey: Key.isEmailEnabled)
        }
    }

    var isNotificationEnabled: Bool {
        get {
            return self.defaults.bool(forKey: Key.isNotificationEnabled)
        }
        set {
            self.defaults.set(newValue, forKey: Key.isNotificationEnabled)
        }
    }
}
