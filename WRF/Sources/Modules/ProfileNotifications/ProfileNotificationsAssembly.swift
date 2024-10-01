import UIKit

final class ProfileNotificationsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ProfileNotificationsPresenter(
            defaultsService: DefaultsService()
        )
        let viewController = ProfileNotificationsViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}