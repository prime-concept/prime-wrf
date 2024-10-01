import PromiseKit
import UIKit

protocol MapFilterPresenterProtocol {
    func loadFilters()
}

final class MapFilterPresenter: MapFilterPresenterProtocol {
    weak var viewController: MapFilterViewControllerProtocol?

    private let endpoint: RestaurantTagsEndpointProtocol
    private let filterIDs: [Tag.IDType]

    init(filterIDs: [Tag.IDType], endpoint: RestaurantTagsEndpointProtocol) {
        self.filterIDs = filterIDs
        self.endpoint = endpoint
    }

    func loadFilters() {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.endpoint.retrieve().result
        }.done { response in
            self.viewController?.set(model: self.makeViewModel(from: response))
        }.catch { error in
            print("map filter presenter: error when loading filters = \(error)")
        }
    }

    // MARK: - Private API

    private func makeViewModel(from model: RestaurantTags) -> MapFilterViewModel {
        return MapFilterViewModel(
            special: model.special.map { TypedTag(tag: $0, type: .special) },
            cuisines: model.cuisines.map { TypedTag(tag: $0, type: .cuisines) },
            restServices: model.restServices.map { TypedTag(tag: $0, type: .restServices) },
            filterIDs: self.filterIDs
        )
    }
}
