import UIKit

final class MyCardInfoAssembly: Assembly {
    private let client: PrimePassClient

    init(client: PrimePassClient) {
        self.client = client
    }

    func makeModule() -> UIViewController {
        let presenter = MyCardInfoPresenter(client: self.client)
        let viewController = MyCardInfoViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
