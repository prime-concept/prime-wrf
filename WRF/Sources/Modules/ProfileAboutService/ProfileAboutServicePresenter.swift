import UIKit

protocol ProfileAboutServicePresenterProtocol {
    var appVersion: String? { get }
}

final class ProfileAboutServicePresenter: ProfileAboutServicePresenterProtocol {
    weak var viewController: ProfileAboutServiceViewControllerProtocol?

    var appVersion: String? {
        let infoDictionary = Bundle.main.infoDictionary ?? [:]
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String
        let minorVersion = infoDictionary["CFBundleVersion"] as? String
        return "\(majorVersion ?? "") (\(minorVersion ?? ""))"
    }
}
