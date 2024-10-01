import PrimeGuideCore
import UIKit

final class MDChatAssemblyConstructor: ChatAssemblyConstructor {
    
    func assembly(
        token: String,
        channelID: String,
        channelName: String,
        clientID: String,
        sourceViewController: UIViewController
    ) -> any Assembly {
        ChatAssembly(
            chatToken: token,
            channelID: channelID,
            channelName: channelName,
            clientID: clientID,
            sourceViewController: sourceViewController
        )
    }
    
}
