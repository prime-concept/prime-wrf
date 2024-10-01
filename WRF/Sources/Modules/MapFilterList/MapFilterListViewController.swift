import UIKit

protocol MapFilterListViewControllerProtocol: AnyObject {
    var selectedIndexes: [Int] { get }

    func set(items: [MapFilterItemViewModel])
}

final class MapFilterListViewController: UIViewController {
    let presenter: MapFilterListPresenterProtocol
    lazy var filterListView = self.view as? MapFilterListView

    private var items: [MapFilterItemViewModel] = []

    init(presenter: MapFilterListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = MapFilterListView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterListView?.updateTableView(delegate: self, dataSource: self)
    }
}

extension MapFilterListViewController: MapFilterListViewControllerProtocol {
    var selectedIndexes: [Int] {
        return self.filterListView?.filtersTableView.indexPathsForSelectedRows?.map { $0.row } ?? []
    }

    func set(items: [MapFilterItemViewModel]) {
        self.items = items
        self.filterListView?.updateTableView(delegate: self, dataSource: self)
    }
}

extension MapFilterListViewController: UITableViewDelegate {}

extension MapFilterListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MapFilterTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let item = self.items[indexPath.row]
        cell.configure(with: item)
        if item.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.filterListView?.appearance.itemHeight ?? -1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
