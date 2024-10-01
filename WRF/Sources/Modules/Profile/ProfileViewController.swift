import DeviceKit
import IQKeyboardManagerSwift
import SnapKit
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    func setProfileImage(_ image: ProfileViewController.ProfileImage)
    func setActiveBookingsCount(_ count: Int)

    func showProfile()
    func showAuthorization()

    func dismiss()
    func showLoyaltyCard()
}

/**
 Merely a dispatcher between Authorization flow and actual Profile content,
 placed in ProfileTabsViewController
 */
final class ProfileViewController: UIViewController, BlockingLoaderPresentable {
    static let floatingControllerGroupID = "profile"

    struct Appearance {
        var titleEditorLineHeight: CGFloat = 20
        var titleLabelTextColor = Palette.shared.textPrimary

        var profileIconSize = CGSize(width: 25, height: 25)
        var settingsIconSize = CGSize(width: 16, height: 16)
        var profileIconTintColor = Palette.shared.iconsPrimary
    }

    enum ProfileImage {
        case authorized(UIImage?)
        case unauthorized
    }

    let appearance: Appearance
    let presenter: ProfilePresenterProtocol

    private lazy var profileView = ProfileView()
    private var tabsViewController: ProfileTabsViewController!
    private lazy var authViewController = AuthAssembly(
        withHeader: false, withLogo: false
    ).makeModule()
    
    private var didAppear = false

    init(presenter: ProfilePresenterProtocol, appearance: Appearance = .init()) {
        self.presenter = presenter
        self.appearance = appearance

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColorThemed = profileView.appearance.backgroundColor
        
        setProfileImage(.unauthorized)

        showSimplestLoader()

        edgesForExtendedLayout = [.top]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !didAppear {
            setupNavigationBar()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didAppear {
            placeContentViews()
            placeAuthView()

            profileView.isHidden = true
            authViewController.view.isHidden = true

            presenter.loadClient()
        }

        navigationController?.navigationBar.tintColorThemed = appearance.profileIconTintColor

        didAppear = true
        presenter.didAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    // MARK: - Private Api

    private func placeContentViews() {
        view.addSubview(profileView)

        profileView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        tabsViewController = ProfileTabsViewController(
            tabsContainer: profileView.tabContainerView
        )

        profileView.contentView.addSubview(tabsViewController.view)
        tabsViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addChild(tabsViewController)
    }

    private func placeAuthView() {
        view.addSubview(authViewController.view)
        authViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        addChild(authViewController)
    }

    private func setupNavigationBar() {
        guard let navigationController else { return }

        let titleLabel = makeTitleLabel()

        if navigationController.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        } else {
            navigationItem.setBackButtonText()
            navigationItem.titleView = titleLabel
        }
    }
    
    func setProfileImage(_ imageType: ProfileViewController.ProfileImage) {
        var size: CGSize
        var imageView: UIImageView

        switch imageType {
            case .authorized(let image):
                size = appearance.profileIconSize
                imageView = makeTitleIcon(image: image)
                break
            case .unauthorized:
                size = appearance.settingsIconSize
                imageView = makeGuestIcon()
                break
        }

        imageView.isUserInteractionEnabled = true
        let profileImageTap = UITapGestureRecognizer(target: self, action: #selector(self.profileClick))
        imageView.addGestureRecognizer(profileImageTap)

        let profileIcon = UIBarButtonItem(customView: imageView)
        profileIcon.customView?.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        self.navigationItem.rightBarButtonItem = profileIcon
    }

    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.attributedText = LineHeightStringMaker.makeString(
            "Профиль",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: UIFont.wrfFont(ofSize: 17)
        )
        label.textColorThemed = self.appearance.titleLabelTextColor
        return label
    }

    func makeTitleIcon(image: UIImage? = nil) -> UIImageView {
        return self.makeIcon(
            image: image ?? #imageLiteral(resourceName: "user-image"),
            size: self.appearance.profileIconSize
        )
    }

    func makeGuestIcon() -> UIImageView {
        let image = #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate)
        return self.makeIcon(
            image: image,
            size: self.appearance.settingsIconSize
        )
    }

    func makeIcon(image: UIImage?, size: CGSize) -> UIImageView {
        let image = UIImageView(image: image)
        image.contentMode = .scaleAspectFill
        image.frame = CGRect(
            x: 0,
            y: 0,
            width: size.width,
            height: size.height
        )
        image.layer.cornerRadius = image.frame.width / 2
        image.layer.masksToBounds = true
        return image
    }

    @objc
    private func profileClick() {
        AnalyticsReportingService.shared.didTransitionToProfileSettings()
        
        let settingsController = ProfileSettingsAssembly().makeModule()
        self.navigationController?.pushViewController(settingsController, animated: true)
    }
}

extension ProfileViewController: ProfileViewControllerProtocol {
    func showProfile() {
        hideSimplestLoader()
        authViewController.view.isHidden = true
        profileView.isHidden = false
    }

    func showAuthorization() {
        hideSimplestLoader()
        authViewController.view.isHidden = false
        profileView.isHidden = true
    }

    func setActiveBookingsCount(_ count: Int) {
        tabsViewController.setActiveBookingsCount(count)
    }
    
    func showLoyaltyCard() {
        tabsViewController.showLoyaltyCard()
    }
    
    func dismiss() {
        self.showLoading()
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.navigationController?.popViewController(animated: true)
            self.hideLoading()
        }
        CATransaction.commit()
    }
}
