import PromiseKit
import UIKit

extension Notification.Name {
    static let logout = Notification.Name("logout")
}

protocol ProfileSettingsPresenterProtocol {
    func getSettingItems() -> [Setting]
    func updateClientInfo(viewModel: ProfileViewModel)

    func checkAuthorization()
    func requestLogout()
    func deleteAccount(completion: @escaping (Bool) -> Void)
}

final class ProfileSettingsPresenter: ProfileSettingsPresenterProtocol {
    private static let defaultProfileImageUploadSize = CGSize(width: 500, height: 500)
    private static let defaultProfileImageUploadQuality: CGFloat = 0.5

    weak var viewController: ProfileSettingsViewControllerProtocol?

    private lazy var guestSettings: [Setting] = {
        return AvailableGuestSettings.settings
    }()

    private lazy var userSettings: [Setting] = {
        var settings: [Setting] = []
        settings.append(
            Setting(
                title: "Редактировать профиль",
                icon: #imageLiteral(resourceName: "settings-profile"),
                type: .profileEdit
            )
        )
        settings.append(contentsOf: self.guestSettings)
        return settings
    }()

    private let clientService: ClientServiceProtocol
    private let authService: AuthServiceProtocol

    init(clientService: ClientServiceProtocol, authService: AuthServiceProtocol) {
        self.clientService = clientService
        self.authService = authService
    }

    func getSettingItems() -> [Setting] {
        return self.authService.isAuthorized ? self.userSettings : self.guestSettings
    }

    func checkAuthorization() {
        self.viewController?.set(isLoggedIn: self.authService.isAuthorized)
    }

    func requestLogout() {
        self.authService.removeAuthorization()
        self.clientService.removeClient()
        NotificationCenter.default.post(name: .logout, object: nil)

        self.viewController?.dismiss()
    }

    func updateClientInfo(viewModel: ProfileViewModel) {
        guard self.authService.isAuthorized else {
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            viewModel.photo.resize(to: ProfileSettingsPresenter.defaultProfileImageUploadSize)
        }
        .compactMap { $0 }
        .then(on: queue) { image in
            image.asBase64String(quality: ProfileSettingsPresenter.defaultProfileImageUploadQuality)
        }.map { base64 in
            ClientUpdateParameters(
                name: viewModel.name,
                surname: viewModel.surname,
                phone: viewModel.phone,
                photo: base64 ?? "",
                email: viewModel.email,
                birthday: viewModel.birthday,
                gender: viewModel.gender
            )
        }.done { client in
            self.clientService.update(client: client)
        }.cauterize()
    }

    func deleteAccount(completion: @escaping (Bool) -> Void) {
        if let id = self.authService.authorizationData?.userID {
            self.clientService.delete(id: id, completion: completion)
        }
    }
}
