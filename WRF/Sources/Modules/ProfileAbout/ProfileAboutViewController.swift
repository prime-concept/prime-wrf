import UIKit

protocol ProfileAboutViewControllerProtocol: AnyObject { }

final class ProfileAboutViewController: UIViewController {
    let presenter: ProfileAboutPresenterProtocol

    lazy var profileAboutView = self.view as? ProfileAboutView

    private var originalTintColor: ThemedColor?
    private var originalBarStyle: UIBarStyle?
    private var wasTranslucent: Bool?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(presenter: ProfileAboutPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = ProfileAboutView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setBackButtonText()

        wasTranslucent = self.navigationController?.navigationBar.isTranslucent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        originalTintColor = navigationController?.navigationBar.tintColorThemed
        originalBarStyle = navigationController?.navigationBar.barStyle

        navigationController?.navigationBar.tintColorThemed = Palette.shared.white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let originalTintColor {
            navigationController?.navigationBar.tintColorThemed = originalTintColor
        }

        if let originalBarStyle {
            navigationController?.navigationBar.barStyle = originalBarStyle
        }

        if let wasTranslucent {
            navigationController?.navigationBar.isTranslucent = wasTranslucent
        }
    }
}

extension ProfileAboutViewController: ProfileAboutViewControllerProtocol { }
