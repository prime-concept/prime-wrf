import UIKit

final class ProfileFaqAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileFaqPresenter()
        let viewController = ProfileFaqViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}