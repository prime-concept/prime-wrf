import PrimeGuideCore
import UIKit

@UIApplicationMain
final class MDAppDelegate: AppDelegate {
    
    override func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        PGCMain.shared.configure(
            chatAssemblyConstructor: MDChatAssemblyConstructor(),
            config: MDConfig(),
            featureFlags: MDFeatureFlags(),
            palette: MDPalette(),
            resourceProvider: MDResourceProvider(),
            text: MDText()
        )
        
        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
}
