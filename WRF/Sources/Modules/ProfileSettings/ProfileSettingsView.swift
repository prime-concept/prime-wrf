import SnapKit
import UIKit

protocol ProfileSettingsViewDelegate: AnyObject {
    func profileSettingsViewDidRequestLogout(_ view: ProfileSettingsView)
}

extension ProfileSettingsView {
    struct Appearance: Codable {
        var settingItemHeight: CGFloat = 48
        var tableViewOffset: CGFloat = 23
        var logoutButtonIconSize = CGSize(width: 13, height: 15)
        var logoutButtonTextColor = Palette.shared.textSecondaryInverse
        var logoutButtonBackgroundColor = Palette.shared.backgroundColor2
        var logoutButtonRightInset: CGFloat = 20
        var logoutButtonLeftInset: CGFloat = 20
        var logoutButtonTopInset: CGFloat = 20
        var logoutButtonSize = CGSize(width: 174, height: 40)
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileSettingsView: UIView {
    let appearance: Appearance
    weak var delegate: ProfileSettingsViewDelegate?

    var isLoggedIn = false {
        didSet {
            self.logoutButton.isHidden = !self.isLoggedIn
        }
    }

    private lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(cellClass: SettingsTableViewCell.self)
        return tableView
    }()

    private lazy var logoutButton: ShadowIconButton = {
        var appearance = ShadowIconButton.Appearance()
        appearance.iconSize = self.appearance.logoutButtonIconSize
        appearance.leftInset = self.appearance.logoutButtonLeftInset
        appearance.rightInset = -self.appearance.logoutButtonRightInset
        appearance.mainTextColor = self.appearance.logoutButtonTextColor
        let button = ShadowIconButton(appearance: appearance)
        button.iconImage = #imageLiteral(resourceName: "settings-logout")
        button.title = "Выйти из аккаунта"
        button.addTarget(self, action: #selector(self.logoutButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
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
        self.settingsTableView.delegate = delegate
        self.settingsTableView.dataSource = dataSource
        self.settingsTableView.reloadData()
    }

    // MARK: - Private API

    @objc
    private func logoutButtonClicked() {
        self.delegate?.profileSettingsViewDidRequestLogout(self)
    }
}

extension ProfileSettingsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.settingsTableView)
        self.addSubview(self.logoutButton)
    }

    func makeConstraints() {
        self.settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.settingsTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        self.logoutButton.translatesAutoresizingMaskIntoConstraints = false
        self.logoutButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.logoutButtonSize)
            make.centerX.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .offset(-self.appearance.logoutButtonTopInset)
            } else {
                make.bottom
                    .equalToSuperview()
                    .offset(-self.appearance.logoutButtonTopInset)
            }
        }
    }
}
