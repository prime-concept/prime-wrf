import UIKit

final class ProfileAboutServiceAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileAboutServicePresenter()
        let viewController = ProfileAboutServiceViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}