import UIKit

public protocol ChatAssemblyConstructor {
    
    func assembly(
        token: String,
        channelID: String,
        channelName: String,
        clientID: String,
        sourceViewController: UIViewController
    ) -> any Assembly
    
}
