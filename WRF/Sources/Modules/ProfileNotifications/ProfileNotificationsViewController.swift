import UIKit

protocol ProfileNotificationsViewControllerProtocol: AnyObject {
    func set(model: ProfileNotificationsViewModel)
}

final class ProfileNotificationsViewController: UIViewController {
    let presenter: ProfileNotificationsPresenterProtocol
    private lazy var profileNotificationsView = self.view as? ProfileNotificationsView

    init(presenter: ProfileNotificationsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileNotificationsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Уведомления"
        self.navigationItem.setBackButtonText()

        self.presenter.viewDidLoad()
    }
}

extension ProfileNotificationsViewController: ProfileNotificationsViewControllerProtocol {
    func set(model: ProfileNotificationsViewModel) {
        self.profileNotificationsView?.update(with: model)
    }
}

extension ProfileNotificationsViewController: ProfileNotificationsViewDelegate {
    func viewDidRequestNotificationsEnable(_ view: ProfileNotificationsView) {
        self.presenter.setNotifications(enabled: true)
        UIApplication.shared.registerForRemoteNotifications()
    }

    func viewDidRequestNotificationsDisable(_ view: ProfileNotificationsView) {
        self.presenter.setNotifications(enabled: false)
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}
