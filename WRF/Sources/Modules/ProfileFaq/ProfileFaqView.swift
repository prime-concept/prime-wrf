import SnapKit
import UIKit

extension ProfileFaqView {
    struct Appearance {
        let itemHeight: CGFloat = 50

        let faqTableTopOffset: CGFloat = 10
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileFaqView: UIView {
    let appearance: Appearance

    private lazy var faqTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: ProfileFaqTableViewCell.self)
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
        self.faqTableView.delegate = delegate
        self.faqTableView.dataSource = dataSource
    }
}

extension ProfileFaqView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.faqTableView)
    }

    func makeConstraints() {
        self.faqTableView.translatesAutoresizingMaskIntoConstraints = false
        self.faqTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.faqTableTopOffset)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
