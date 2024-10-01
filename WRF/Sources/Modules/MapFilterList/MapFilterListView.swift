import SnapKit
import UIKit

extension MapFilterListView {
    struct Appearance {
        let itemHeight: CGFloat = 48
    }
}

final class MapFilterListView: UIView {
    let appearance: Appearance

    private(set) lazy var filtersTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.allowsMultipleSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: MapFilterTableViewCell.self)
        return tableView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public api

    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.filtersTableView.delegate = delegate
        self.filtersTableView.dataSource = dataSource
        self.filtersTableView.reloadData()
    }
}

extension MapFilterListView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.filtersTableView)
    }

    func makeConstraints() {
        self.filtersTableView.translatesAutoresizingMaskIntoConstraints = false
        self.filtersTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
}
