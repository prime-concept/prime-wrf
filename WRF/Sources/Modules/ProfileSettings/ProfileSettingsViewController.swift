import SafariServices
import UIKit

protocol ProfileSettingsViewControllerProtocol: AnyObject {
    func set(isLoggedIn: Bool)
    func dismiss()
}

protocol ProfileSettingsDelegate: AnyObject {
    func didRequestProfileUpdate(viewModel: ProfileViewModel)
}

final class ProfileSettingsViewController: UIViewController, BlockingLoaderPresentable {
    private static let debounceAnimationInterval: TimeInterval = 0.25

    let presenter: ProfileSettingsPresenterProtocol
    lazy var profileSettingsView = self.view as? ProfileSettingsView

    private lazy var settingItems = self.presenter.getSettingItems()

    init(presenter: ProfileSettingsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileSettingsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Настройки"
        self.navigationItem.setBackButtonText()
        self.profileSettingsView?.updateTableView(delegate: self, dataSource: self)

        self.presenter.checkAuthorization()
    }
}

extension ProfileSettingsViewController: ProfileSettingsViewControllerProtocol {
    func set(isLoggedIn: Bool) {
        self.profileSettingsView?.isLoggedIn = isLoggedIn
    }

    func dismiss() {
        self.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + ProfileSettingsViewController.debounceAnimationInterval) {
            self.navigationController?.popViewController(animated: true)
            self.hideLoading()
        }
    }
}

extension ProfileSettingsViewController: ProfileSettingsDelegate {
    func didRequestProfileUpdate(viewModel: ProfileViewModel) {
        self.presenter.updateClientInfo(viewModel: viewModel)
    }
}

extension ProfileSettingsViewController: UITableViewDelegate { }

extension ProfileSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let item = self.settingItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.profileSettingsView?.appearance.settingItemHeight ?? -1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        var viewController: UIViewController?

        let item = self.settingItems[indexPath.row]
        switch item.type {
        case .profileEdit:
            viewController = ProfileEditAssembly().makeModule()
            if let profileEditViewController = viewController as? ProfileEditViewController {
                profileEditViewController.delegate = self
            }
        case .notifications:
            viewController = ProfileNotificationsAssembly().makeModule()
        case .paymentMethods:
            viewController = ProfilePaymentsAssembly().makeModule()
        case .feedback:
            viewController = ProfileFeedbackAssembly().makeModule()
        case .faq:
            viewController = ProfileFaqAssembly().makeModule()
        case .about:
            viewController = ProfileAboutAssembly().makeModule()
        case .contactUs:
            viewController = ProfileContactsAssembly().makeModule()
        case .aboutService:
            viewController = ProfileAboutServiceAssembly().makeModule()
        case .loyaltyProgramRules:
            viewController = SFSafariViewController(url: PGCMain.shared.config.loyaltyRulesURL)
        case .privacyPolicy:
            viewController = SFSafariViewController(url: PGCMain.shared.config.privacyPolicyURL)
        case .termsOfUse:
            viewController = PGCMain.shared.featureFlags.profile.shouldOpenDocumentsInSafari
                ? SFSafariViewController(url: PGCMain.shared.config.termsOfUseURL)
                : WebFrameAssembly(frameData: .userAgreement).makeModule()
        case .forPartners:
            viewController = WebFrameAssembly(frameData: .forPartners).makeModule()
        case .profileDeletion:
            viewController = self.makeDeletionModule()
        }

        if let viewController = viewController {
            switch item.type {
            case .privacyPolicy, .termsOfUse, .forPartners, .loyaltyProgramRules, .profileDeletion:
                self.present(viewController, animated: true, completion: nil)
            default:
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    private func makeDeletionModule() -> UIAlertController {
        let dialogController = UIAlertController(
            title: "Удаление аккаунта",
            message: "Вы уверены, что хотите удалить свой аккаунт?",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let deletionAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.showLoading()
            self.presenter.deleteAccount { [weak self] isAccDeleted in
                self?.hideLoading()
                isAccDeleted ? self?.alertAccountDeleted() : self?.alertAccountDeletionFailed()
            }
        }
        dialogController.addAction(cancelAction)
        dialogController.addAction(deletionAction)
        return dialogController
    }

    private func alertAccountDeleted() {
        let dialogController = UIAlertController(
            title: nil,
            message: "Данные вашего аккаунта успешно удалены",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.presenter.requestLogout()
        }
        dialogController.addAction(okAction)
        self.present(dialogController, animated: true)
    }

    private func alertAccountDeletionFailed() {
        let dialogController = UIAlertController(
            title: nil,
            message: "Не удалось удалить данные вашего профиля. Попробуйте позже.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default)
        dialogController.addAction(okAction)
        self.present(dialogController, animated: true)
    }
}

extension ProfileSettingsViewController: ProfileSettingsViewDelegate {
    func profileSettingsViewDidRequestLogout(_ view: ProfileSettingsView) {
        self.presenter.requestLogout()
    }
}
