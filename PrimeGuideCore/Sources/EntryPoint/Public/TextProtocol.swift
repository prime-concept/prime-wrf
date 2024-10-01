// TODO: Rename to `Text` when doing so won’t result in name collision
public protocol TextProtocol {
    var about: String { get }
    var aboutTitle: String { get }
    var service: String { get }
    var shareText: String { get }

    var onboardingNotificationStep: String { get }
    var onboardingGeolocationStep: String { get }
    var onboardingSignInStep: String { get }
}
