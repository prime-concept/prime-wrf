import UIKit

// MARK: - View Controller

final class RootModuleContainerViewController: UIViewController {
    
    private let rootModule: any RootModule

    private lazy var defaultsService = DefaultsService()

    init() {
        rootModule = Self.makeRootModule()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func makeRootModule() -> any RootModule {
        switch PGCMain.shared.featureFlags.appSetup.navigationMode {
        case .tabbed:
            RootTabBarController()
        case .homeScreen:
			HomeScreenNavigationController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(rootModule)
        rootModule.view.frame = view.bounds
        view.addSubview(rootModule.view)
        rootModule.didMove(toParent: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showOnboardingIfNeeded()
    }

    private func showOnboardingIfNeeded() {
        if self.defaultsService.isOnboardingShown {
            return
        }

        self.defaultsService.isOnboardingShown = true

        let onboardingController = OnboardingAssembly().makeModule()
        onboardingController.modalPresentationStyle = .fullScreen

        self.present(onboardingController, animated: true, completion: nil)
    }

}

// MARK: - RootModuleContainer

extension RootModuleContainerViewController: RootModuleContainer {
    
    func handleDeepLink(_ context: DeeplinkContext) {
        rootModule.route(using: context)
    }
    
}
