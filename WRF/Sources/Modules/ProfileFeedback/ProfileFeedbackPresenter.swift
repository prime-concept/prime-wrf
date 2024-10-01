import PromiseKit
import UIKit

protocol ProfileFeedbackPresenterProtocol {
    func loadClientInfo()
    func submit(model: ProfileFeedbackViewModel)
}

final class ProfileFeedbackPresenter: ProfileFeedbackPresenterProtocol {
    private static let imageQuality: CGFloat = 0.5

    weak var viewController: ProfileFeedbackViewControllerProtocol?

    private let feedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let clientService: ClientServiceProtocol
    private var userID: Int?

    init(
        feedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        clientService: ClientServiceProtocol
    ) {
        self.feedbackEndpoint = feedbackEndpoint
        self.clientService = clientService
    }

    func loadClientInfo() {
        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.clientService.retrieve()
        }
        .done { client in
            guard let client = client else {
                return
            }
            self.userID = client.userID
            self.viewController?.showClientInfo(self.makeViewModel(client: client))
        }.catch { error in
            print("profile feedback presenter: error loading client \(String(describing: error.localizedDescription))")
        }
    }

    func submit(model: ProfileFeedbackViewModel) {
        self.viewController?.showLoading()

        guard let userID = self.userID else {
            self.viewController?.hideLoading()
            self.viewController?.showMessage(isSuccess: false)
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            when(
                fulfilled: model.images.map {
                    $0.asBase64String(
                        quality: ProfileFeedbackPresenter.imageQuality
                    ).compactMap { $0 }
                }
            )
        }
        .map { images in
            return PrimePassAppFeedbackRequest(
                userID: userID,
                type: model.type.rawValue,
                email: model.email,
                phone: model.phone,
                review: model.review,
                images: images
            )
        }.then(on: queue) { request in
             self.feedbackEndpoint.createAppFeedback(request: request).result
        }.done { _ in
            self.viewController?.showMessage(isSuccess: true)
        }.ensure {
            self.viewController?.hideLoading()
        }.catch { _ in
            self.viewController?.showMessage(isSuccess: false)
        }
    }

    // MARK: - Private

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
