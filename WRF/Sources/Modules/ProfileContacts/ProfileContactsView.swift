import SnapKit
import UIKit

extension ProfileContactsView {
    struct Appearance {
        let itemHeight: CGFloat = 62
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileContactsView: UIView {
    let appearance: Appearance

    private lazy var contactsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: ProfileContactsTableViewCell.self)
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
        self.contactsTableView.delegate = delegate
        self.contactsTableView.dataSource = dataSource
        self.contactsTableView.reloadData()
    }
}

extension ProfileContactsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.contactsTableView)
    }

    func makeConstraints() {
        self.contactsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.contactsTableView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }
    }
}
