import UIKit

final class ProfileFeedbackAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileFeedbackPresenter(
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
            clientService: ClientService.shared
        )

        let viewController = ProfileFeedbackViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
