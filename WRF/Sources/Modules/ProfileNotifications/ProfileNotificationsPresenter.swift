import UIKit

protocol ProfileNotificationsPresenterProtocol {
    func viewDidLoad()
    func setNotifications(enabled: Bool)
}

final class ProfileNotificationsPresenter: ProfileNotificationsPresenterProtocol {
    weak var viewController: ProfileNotificationsViewControllerProtocol?

    private let defaultsService: DefaultsServiceProtocol

    init(defaultsService: DefaultsServiceProtocol) {
        self.defaultsService = defaultsService
    }

    func viewDidLoad() {
        let model = ProfileNotificationsViewModel(
            isEmailEnabled: self.defaultsService.isEmailEnabled,
            isNotificationEnabled: self.defaultsService.isNotificationEnabled
        )
        self.viewController?.set(model: model)
    }

    func setNotifications(enabled: Bool) {
        self.defaultsService.isNotificationEnabled = enabled
    }
}
