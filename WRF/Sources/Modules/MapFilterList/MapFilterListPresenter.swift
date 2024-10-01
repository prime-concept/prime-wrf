import UIKit

protocol MapFilterListPresenterProtocol {
}

final class MapFilterListPresenter: MapFilterListPresenterProtocol,
        MapFilterListModuleInput, MapFilterListModuleOutput {
    weak var viewController: MapFilterListViewControllerProtocol?

    var selectedTags: [TypedTag] {
        let indexes = self.viewController?.selectedIndexes ?? []
        return self.tags.enumerated().filter { indexes.contains($0.offset) }.compactMap { $1 }
    }

    private var tags: [TypedTag] = []
    private var selectedIDs: [Tag.IDType] = []

    // MARK: - Public API

    func set(items: [TypedTag], selectedIDs: [Tag.IDType]) {
        self.tags = items
        self.selectedIDs = selectedIDs

        let viewModels = items.enumerated().compactMap(self.makeViewModel)
        self.viewController?.set(items: viewModels)
    }

    // MARK: - Private API

    private func makeViewModel(index: Int, from model: TypedTag) -> MapFilterItemViewModel {
        return MapFilterItemViewModel(
            id: index,
            title: model.tag.title.capitalized,
            isSelected: self.selectedIDs.contains(model.tag.id)
        )
    }
}
