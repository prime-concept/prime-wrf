import UIKit

final class OnboardingAssembly: Assembly {
    func makeModule() -> UIViewController {
        return OnboardingViewController()
    }
}
