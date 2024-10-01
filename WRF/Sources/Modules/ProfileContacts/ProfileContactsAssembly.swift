import UIKit

final class ProfileContactsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileContactsPresenter(endpoint: ContactsEndpoint())
        let viewController = ProfileContactsViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}