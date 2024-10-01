import UIKit

final class NotificationsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = NotificationsPresenter(
            notificationEndpoint: PrimePassNotifyEndpoint(),
            authService: AuthService(),
            notificationPersistenceService: NotificationPersistenceService()
        )
        let viewController = NotificationsViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
