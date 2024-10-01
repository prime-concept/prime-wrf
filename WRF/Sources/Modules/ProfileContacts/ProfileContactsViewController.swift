import UIKit

protocol ProfileContactsViewControllerProtocol: AnyObject {
    func set(contacts: [ProfileContactItemViewModel])
    func open(url: URL)
}

final class ProfileContactsViewController: UIViewController {
    let presenter: ProfileContactsPresenterProtocol
    private lazy var profileContactsView = self.view as? ProfileContactsView

    private var contacts: [ProfileContactItemViewModel] = []

    init(presenter: ProfileContactsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileContactsView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Контакты"
        self.navigationItem.setBackButtonText()

        self.presenter.loadContacts()
    }
}

extension ProfileContactsViewController: ProfileContactsViewControllerProtocol {
    func set(contacts: [ProfileContactItemViewModel]) {
        self.contacts = contacts
        self.profileContactsView?.updateTableView(delegate: self, dataSource: self)
    }

    func open(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ProfileContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.profileContactsView?.appearance.itemHeight ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.presenter.select(at: indexPath.row)
    }
}

extension ProfileContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileContactsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let model = self.contacts[safe: indexPath.row] {
            cell.configure(with: model)
        }
        return cell
    }
}
