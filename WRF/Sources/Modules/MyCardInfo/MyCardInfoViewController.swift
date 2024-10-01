import SafariServices
import UIKit

protocol MyCardInfoViewControllerProtocol: AnyObject {
    func set(model: MyCardInfoViewModel)
}

final class MyCardInfoViewController: UIViewController {
    let presenter: MyCardInfoPresenterProtocol
    private lazy var myCardInfoView = self.view as? MyCardInfoView

    init(presenter: MyCardInfoPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        if PGCMain.shared.featureFlags.loyalty.showsPersonifiedFeatures {
            let view = MyCardInfoView(frame: UIScreen.main.bounds)
            self.view = view
        } else {
            let view = MyCardInfoPlaceholderView(frame: UIScreen.main.bounds)
            self.view = view
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadCard()

        self.myCardInfoView?.onRulesLinkClick = { [weak self] in
            self?.presentLoyaltyRules()
        }
    }

    private func presentLoyaltyRules() {
        let controller = SFSafariViewController(url: PGCMain.shared.config.loyaltyRulesURL)
        self.present(controller, animated: true, completion: nil)
    }
}

extension MyCardInfoViewController: MyCardInfoViewControllerProtocol {
    func set(model: MyCardInfoViewModel) {
		self.myCardInfoView?.balance = model.balance
        self.myCardInfoView?.gradeName = model.gradeName
        self.myCardInfoView?.userImage = model.userImage
        self.myCardInfoView?.descriptionText = model.description
    }
}
