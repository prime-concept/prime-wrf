import UIKit

protocol NotificationsViewControllerProtocol: AnyObject {
    func set(notifications: [NotificationSectionViewModel])
}

final class NotificationsViewController: UIViewController {
    let presenter: NotificationsPresenterProtocol
    private lazy var notificationsView = self.view as? NotificationsView

    private var notifications: [NotificationSectionViewModel] = []

    init(presenter: NotificationsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NotificationsView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Уведомления"
        self.notificationsView?.updateTableView(delegate: self, dataSource: self)

        self.presenter.loadNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension NotificationsViewController: NotificationsViewControllerProtocol {
    func set(notifications: [NotificationSectionViewModel]) {
        self.notifications = notifications
        self.notificationsView?.showEmptyView = notifications.isEmpty
        self.notificationsView?.updateTableView(delegate: self, dataSource: self)
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.notificationsView?.makeSectionLabel(
            self.notifications[safe: section]?.name ?? ""
        )
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.notificationsView?.appearance.sectionHeight ?? -1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications[section].notifications.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NotificationsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let notification = self.notifications[safe: indexPath.section]?.notifications[safe: indexPath.row] {
            cell.configure(with: notification)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let notification = self.notifications[safe: indexPath.section]?.notifications[safe: indexPath.row] else {
            return 150.0
        }

        return NotificationsItemView.itemHeight(
            for: notification.message,
            time: notification.messageTime,
            width: self.notificationsView?.bounds.width ?? 0
        )
    }
}
