import ChatSDK
import PrimeGuideCore
import UIKit

final class ChatAssembly: Assembly {
    private lazy var chatConfiguration = Chat.Configuration(
        chatBaseURL: PGCMain.shared.config.chatBaseURL,
        storageBaseURL: PGCMain.shared.config.chatStorageURL,
        initialTheme: Theme(
            palette: ChatPalette(),
            imageSet: ChatImageSet(),
            styleProvider: ChatStyleProvider(),
            fontProvider: ChatFontProvider()
        ),
        featureFlags: Chat.Configuration.FeatureFlags.all(except: .canSendContactMessage),
        clientAppID: PGCMain.shared.config.chatClientAppID
    )

    private let sourceViewController: UIViewController

    private let chatToken: String
    private let channelID: String
    private let channelName: String
    private let clientID: String

    init(
        chatToken: String,
        channelID: String,
        channelName: String,
        clientID: String,
        sourceViewController: UIViewController
    ) {
        self.chatToken = chatToken
        self.channelID = channelID
        self.channelName = channelName
        self.clientID = clientID
        self.sourceViewController = sourceViewController
    }

    func makeModule() -> UIViewController {
        let chat = Chat(
            configuration: self.chatConfiguration,
            accessToken: self.chatToken,
            clientID: self.clientID
        )

        let navigationController = ChatNavigationViewController()
        let channelModule = chat.makeChannelModule(for: self.channelID, output: navigationController)
        let channelViewController = channelModule.viewController

        let closeItem = UIBarButtonItem(
            title: "Закрыть",
            style: .plain,
            target: navigationController,
            action: #selector(ChatNavigationViewController.onCloseButtonTap)
        )

        channelViewController.title = "Заказ \(self.channelName)"
        channelViewController.navigationItem.setLeftBarButton(closeItem, animated: false)

        navigationController.setViewControllers([channelViewController], animated: false)

        return navigationController
    }
}

private final class ChatNavigationViewController: UINavigationController, ChannelModuleOutputProtocol {
    func requestPhoneCall(number: String) {
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func requestPresentation(for controller: UIViewController, completion: (() -> Void)?) {
        self.present(controller, animated: true, completion: completion)
    }

    @objc
    func onCloseButtonTap() {
        self.dismiss(animated: true, completion: nil)
    }
}
