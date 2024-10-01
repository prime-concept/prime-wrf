import SnapKit
import UIKit

extension NotificationsView {
    struct Appearance {
        let sectionLabelFont = UIFont.wrfFont(ofSize: 11, weight: .medium)
        let sectionLabelTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let sectionLabelEditorLineHeight: CGFloat = 13
        let sectionLabelInsets = LayoutInsets(left: 15)

        let sectionHeight: CGFloat = 33
        let topOffset: CGFloat = 0
    }
}

final class NotificationsView: UIView {
    let appearance: Appearance

    var showEmptyView: Bool = true {
        didSet {
            self.emptyView.isHidden = !self.showEmptyView
            self.emptyView.state = self.showEmptyView ? .noData : .loading
        }
    }

    private lazy var emptyView: EmptyDataView = {
        let view = EmptyDataView()
        view.title = "У вас еще нет уведомлений"
        view.image = UIImage(named: "notifications-bell-logo")
        return view
    }()

    private lazy var notificationsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(cellClass: NotificationsTableViewCell.self)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.contentInset = UIEdgeInsets(
            top: self.appearance.topOffset,
            left: 0,
            bottom: 0,
            right: 0
        )
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

    // MARK: - Public API

    func updateTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        self.notificationsTableView.delegate = delegate
        self.notificationsTableView.dataSource = dataSource
        self.notificationsTableView.reloadData()
    }

    func makeSectionLabel(_ title: String) -> UIView {
        let view = UIView()
        let sectionLabel = UILabel()
        sectionLabel.font = self.appearance.sectionLabelFont
        sectionLabel.textColor = self.appearance.sectionLabelTextColor
        sectionLabel.attributedText = LineHeightStringMaker.makeString(
            title.uppercased(),
            editorLineHeight: self.appearance.sectionLabelEditorLineHeight,
            font: self.appearance.sectionLabelFont
        )
        view.addSubview(sectionLabel)
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.sectionLabelInsets.left)
            make.bottom.equalToSuperview()
        }
        return view
    }
}

extension NotificationsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = Palette.shared.backgroundColor0
    }

    func addSubviews() {
        self.addSubview(self.notificationsTableView)
        self.addSubview(self.emptyView)
    }

    func makeConstraints() {
        self.notificationsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.notificationsTableView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }

        self.emptyView.translatesAutoresizingMaskIntoConstraints = false
        self.emptyView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.bottom.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }
    }
}
