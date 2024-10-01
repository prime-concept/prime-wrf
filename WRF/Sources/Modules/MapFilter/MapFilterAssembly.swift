import UIKit

final class MapFilterAssembly: Assembly {
    private let selectedFilterIDs: [Tag.IDType]

    init(selectedFilterIDs: [Tag.IDType]) {
        self.selectedFilterIDs = selectedFilterIDs
    }

    func makeModule() -> UIViewController {
        let presenter = MapFilterPresenter(
            filterIDs: self.selectedFilterIDs,
            endpoint: RestaurantTagsEndpoint()
        )
        let viewController = MapFilterViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
