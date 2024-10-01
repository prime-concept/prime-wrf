import UIKit

final class ProfileAboutAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileAboutPresenter()
        let viewController = ProfileAboutViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}