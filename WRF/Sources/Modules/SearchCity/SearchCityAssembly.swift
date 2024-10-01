import UIKit

final class SearchCityAssembly: Assembly {

    var selectedCity: SearchCityViewModel? = nil

    func makeModule() -> UIViewController {
        let presenter = SearchCityPresenter(endpoint: SearchCitiesEndpoint())
        let viewController = SearchCityViewController(
            presenter: presenter,
            selectedCity: selectedCity
        )
        presenter.viewController = viewController

        return viewController
    }
}
