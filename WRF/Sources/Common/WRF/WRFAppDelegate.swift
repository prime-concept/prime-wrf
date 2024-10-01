import PrimeGuideCore
import UIKit

@UIApplicationMain
final class WRFAppDelegate: AppDelegate {
    
    override func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        PGCMain.shared.configure(
            chatAssemblyConstructor: WRFChatAssemblyConstructor(),
            config: WRFConfig(),
            featureFlags: FeatureFlags(),
            palette: Palette(),
            resourceProvider: WRFResourceProvider(),
            text: Text()
        )
        
        return super.application(application, willFinishLaunchingWithOptions: launchOptions)
    }
    
}
