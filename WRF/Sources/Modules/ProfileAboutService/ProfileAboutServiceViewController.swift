import UIKit

protocol ProfileAboutServiceViewControllerProtocol: AnyObject { }

final class ProfileAboutServiceViewController: UIViewController {
    let presenter: ProfileAboutServicePresenterProtocol

    lazy var serviceView = self.view as? ProfileAboutServiceView

    init(presenter: ProfileAboutServicePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileAboutServiceView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "О сервисе"
        self.navigationItem.setBackButtonText()

        self.serviceView?.version = self.presenter.appVersion
        self.serviceView?.text = PGCMain.shared.text.service
    }
}

extension ProfileAboutServiceViewController: ProfileAboutServiceViewControllerProtocol { }
