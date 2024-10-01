import UIKit

protocol ProfileFaqDetailViewControllerProtocol: AnyObject {
    func set(title: String, text: String)
}

final class ProfileFaqDetailViewController: UIViewController {
    let presenter: ProfileFaqDetailPresenterProtocol
    private lazy var profileFaqDetailView = self.view as? ProfileFaqDetailView

    private var originalTintColor: ThemedColor?
    private var wasTranslucent: Bool?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(presenter: ProfileFaqDetailPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileFaqDetailView(frame: UIScreen.main.bounds)
        view.scrollView.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setBackButtonText()

        wasTranslucent = self.navigationController?.navigationBar.isTranslucent

        self.presenter.loadFaqDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.tintColorThemed = Palette.shared.white
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let originalTintColor {
            navigationController?.navigationBar.tintColorThemed = originalTintColor
        }

        if let wasTranslucent {
            navigationController?.navigationBar.isTranslucent = wasTranslucent
        }
    }
}

extension ProfileFaqDetailViewController: ProfileFaqDetailViewControllerProtocol {
    func set(title: String, text: String) {
        self.profileFaqDetailView?.title = title
        self.profileFaqDetailView?.text = text
    }
}

extension ProfileFaqDetailViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.profileFaqDetailView?.scrollView else {
            return
        }

        // Disable top bounce, 100pt - is just small magic gap
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
}
