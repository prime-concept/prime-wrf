import UIKit

final class SearchAssembly: Assembly {
    private let page: PageContext

    init(page: PageContext = .restaurants) {
        self.page = page
    }

    func makeModule() -> UIViewController {
        let presenter = SearchPresenter()
        let viewController = SearchViewController(
            presenter: presenter,
            scrollTo: self.page
        )
        presenter.viewController = viewController

        return viewController
    }
}