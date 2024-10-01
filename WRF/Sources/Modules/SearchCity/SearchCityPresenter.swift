import UIKit

protocol SearchCityPresenterProtocol {
    var citiesCallback: ((SearchCitiesViewModel) -> Void)? { get set }
    func viewDidLoad()
    func getCitiesViewModels() -> SearchCitiesViewModel
}

final class SearchCityPresenter: SearchCityPresenterProtocol {

    // MARK: - fields

    weak var viewController: SearchCityViewControllerProtocol?
    private var endpoint: SearchCitiesEndpointProtocol

    private(set) lazy var cities: SearchCitiesModel = .init(cities: [])

    // MARK: - callbacks

    var citiesCallback: ((SearchCitiesViewModel) -> Void)?

    // MARK: - life cycle

    init(
        endpoint: SearchCitiesEndpointProtocol
    ) {
        self.endpoint = endpoint
    }

    func viewDidLoad() {
        loadCities()
    }

    // MARK: - interactions

    func getCitiesViewModels() -> SearchCitiesViewModel {
        SearchCitiesViewModel(
            cities: cities.cities.compactMap {
                SearchCityViewModel(
                    id: $0.id,
                    title: $0.title,
                    coordinates: .init(
                            latitude: $0.coordinates.latitude,
                            longitude: $0.coordinates.longitude
                        )
                )
            }
        )
    }

    private func loadCities() {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.endpoint.retrieve().result
        }.done { response in
            self.cities = response
            self.citiesCallback?(self.getCitiesViewModels())
        }.catch { error in
            print("the request of cities has the error: \(String(describing: error))")
        }
    }
}
