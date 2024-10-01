import PromiseKit
import UIKit

extension Notification.Name {
    static let clientUpdated = Notification.Name("clientUpdated")
}

protocol ProfileEditPresenterProtocol {
    func loadClientInfo()

    func isProfileChanged(model: ProfileViewModel) -> Guarantee<Bool>
}

final class ProfileEditPresenter: ProfileEditPresenterProtocol {
    weak var viewController: ProfileEditViewControllerProtocol?

    private let clientEndpoint: PrimePassClientEndpointProtocol
    private let clientService: ClientServiceProtocol
    private let authService: AuthServiceProtocol

    init(
        clientEndpoint: PrimePassClientEndpointProtocol,
        clientService: ClientServiceProtocol,
        authService: AuthServiceProtocol
    ) {
        self.clientEndpoint = clientEndpoint
        self.clientService = clientService
        self.authService = authService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.loadClientInfo),
            name: .clientUpdated,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    @objc
    func loadClientInfo() {
        guard let userID = self.authService.authorizationData?.userID else {
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.clientService.retrieve()
        }
        .done { client in
            guard let client = client else {
                return
            }
            self.viewController?.showClientInfo(self.makeViewModel(client: client))
        }.then(on: queue) {
            self.clientEndpoint.retrieve(id: userID).result
        }.done(on: queue) { response in
            guard response.status == .ok,
                  let client = response.data else {
                return
            }
            self.clientService.save(client: client)
            DispatchQueue.main.async {
                self.viewController?.showClientInfo(self.makeViewModel(client: client))
            }
        }.catch { error in
            print("profile edit presenter: error loading client \(String(describing: error.localizedDescription))")
        }
    }

    func isProfileChanged(model: ProfileViewModel) -> Guarantee<Bool> {
        Guarantee { seal in
            self.clientService.retrieve().done { client in
                guard let client = client else {
                    return
                }

                let lastModel = self.makeViewModel(client: client)

                let isChanged =
                    model.name != lastModel.name ||
                    model.surname != lastModel.surname ||
                    model.phone != lastModel.phone ||
                    model.email != lastModel.email ||
                    model.photo.pngData() != lastModel.photo.pngData() ||
                    (model.birthday != lastModel.birthday) && !model.birthday.isEmpty ||
                    model.gender != lastModel.gender

                seal(isChanged)
            }
        }
    }

    private func makeViewModel(client: PrimePassClient) -> ProfileViewModel {
        return ProfileViewModel(
            name: client.name ?? "",
            surname: client.surname ?? "",
            phone: client.phone,
            email: client.email ?? "",
            photo: client.photo?.asImage ?? #imageLiteral(resourceName: "user-image"),
            birthday: client.birthday?.unformatDate() ?? "",
            gender: client.gender
        )
    }
}
