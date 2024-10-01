import UIKit

final class ProfileFaqDetailAssembly: Assembly {
    private let model: ProfileFaqViewModel

    init(model: ProfileFaqViewModel) {
        self.model = model
    }

    func makeModule() -> UIViewController {
        let presenter = ProfileFaqDetailPresenter(model: self.model)
        let viewController = ProfileFaqDetailViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}