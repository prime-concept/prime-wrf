import PrimeGuideCore
import UIKit

@UIApplicationMain
final class FHAppDelegate: AppDelegate {
    
    override func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        PGCMain.shared.configure(
            chatAssemblyConstructor: FHChatAssemblyConstructor(),
            config: FHConfig(),
            featureFlags: FHFeatureFlags(),
            palette: FHPalette(),
            resourceProvider: FHResourceProvider(),
            text: FHText()
        )
        
        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
}
