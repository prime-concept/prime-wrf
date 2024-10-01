import SnapKit
import UIKit

extension SearchDeliveryView {
    struct Appearance {
        let itemHeight: CGFloat = 100
        let topViewOffset: CGFloat = 130
    }
}

final class SearchDeliveryView: UIView {
    let appearance: Appearance

    enum State {
        case querySearchIsEmpty
        case data(hasData: Bool)
    }

    var state: State = .data(hasData: false) {
        didSet {
            switch self.state {
            case .data(let hasData):
                self.emptyView.state = .noData
                self.emptyView.title = "Данных нет"
                self.restaurantsTableView.backgroundView?.isHidden = hasData
            case .querySearchIsEmpty:
                self.emptyView.state = .noData
                self.emptyView.title = "По вашему запросу ничего\nне найдено"
                self.restaurantsTableView.backgroundView?.isHidden = false
            }
        }
    }

    private lazy var emptyView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "Данных нет"
        view.image = #imageLiteral(resourceName: "search")
        return view
    }()

    private lazy var topView = UIView()

    private(set) lazy var restaurantsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: SearchDeliveryTableViewCell.self)
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.restaurantsTableView.backgroundView = self.emptyView
    }

    // MARK: - Public API

    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.restaurantsTableView.delegate = delegate
        self.restaurantsTableView.dataSource = dataSource
        self.restaurantsTableView.reloadData()
    }
}

extension SearchDeliveryView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.topView)
        self.addSubview(self.restaurantsTableView)
    }

    func makeConstraints() {
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.topView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
                    .offset(self.appearance.topViewOffset)
            } else {
                make.top
                    .equalToSuperview()
                    .offset(self.appearance.topViewOffset)
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }

        self.restaurantsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.restaurantsTableView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
