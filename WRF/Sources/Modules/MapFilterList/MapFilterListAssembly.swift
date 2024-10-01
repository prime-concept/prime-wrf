import UIKit

final class MapFilterListAssembly: MapFilterListChildAssembly {
    private lazy var presenter = MapFilterListPresenter()

    var moduleInput: MapFilterListModuleInput {
        return self.presenter
    }

    var moduleOutput: MapFilterListModuleOutput {
        return self.presenter
    }

    func makeModule() -> UIViewController {
        let viewController = MapFilterListViewController(presenter: self.presenter)
        self.presenter.viewController = viewController

        return viewController
    }
}
