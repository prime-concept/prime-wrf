import Pageboy
import Tabman
import UIKit

protocol MapFilterViewControllerProtocol: AnyObject {
    func set(model: MapFilterViewModel)
}

protocol MapFilterViewDelegate: AnyObject {
    func filterViewDidSelectTags(tags: [TypedTag])
}

private enum FilterItem: Int {
    case cuisines
    case special
    case restServices
}

final class MapFilterViewController: TabmanViewController {
    static let floatingControllerGroupID = "filter"

    let presenter: MapFilterPresenterProtocol
    lazy var filterView = self.view as? MapFilterView

    weak var filterDelegate: MapFilterViewDelegate?

    private let barTitles = ["Кухня", "Спецпредложения", "Услуги"]

    private var controllerInputs: [MapFilterListModuleInput] = []
    private var controllerOutputs: [MapFilterListModuleOutput] = []

    private var barItems: [WRFBarItem] = []

    private lazy var barDataSource = TabDataSource(
        items: self.barItems,
        offset: self.filterView?.appearance.tabContentTopOffset ?? 0
    )

    init(presenter: MapFilterPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = MapFilterView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.barTitles.forEach { title in
            let assembly = MapFilterListAssembly()
            self.controllerInputs.append(assembly.moduleInput)
            self.controllerOutputs.append(assembly.moduleOutput)
            self.barItems.append((title: title, viewController: assembly.makeModule()))
        }

        self.dataSource = self.barDataSource

        if let filterView = self.filterView {
            self.setupTabBar(filterView)
        }

        self.presenter.loadFilters()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.filterDelegate?.filterViewDidSelectTags(
            tags: self.controllerOutputs.flatMap { $0.selectedTags }
        )
    }

    // MARK: - Private api

    private func setupTabBar(_ view: MapFilterView) {
        let barLocation: BarLocation = .custom(
            view: view.tabContainerView,
            layout: { bar in
                bar.translatesAutoresizingMaskIntoConstraints = false
                bar.snp.makeConstraints { make in
                    make.top
                        .equalToSuperview()
                        .offset(view.appearance.tabBarTopOffset)
                    make.leading.trailing.bottom.equalToSuperview()
                }
            }
        )
        self.addBar(view.makeTabBar(), dataSource: self.barDataSource, at: barLocation)
    }
}

extension MapFilterViewController: MapFilterViewControllerProtocol {
    func set(model: MapFilterViewModel) {
        self.controllerInputs[FilterItem.cuisines.rawValue].set(items: model.cuisines, selectedIDs: model.filterIDs)
        self.controllerInputs[FilterItem.special.rawValue].set(items: model.special, selectedIDs: model.filterIDs)
        self.controllerInputs[FilterItem.restServices.rawValue].set(
            items: model.restServices,
            selectedIDs: model.filterIDs
        )
    }
}
