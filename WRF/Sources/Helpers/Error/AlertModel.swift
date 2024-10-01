import UIKit

/// The system alert data model
struct AlertModel {

    var title: String? = nil
    var message: String? = nil
    let actions: [Action]
}

extension AlertModel {

    /// The action model of alert
    struct Action {

        let title: String
        var style: UIAlertAction.Style = .default
        var handler: ((UIAlertAction) -> Void)? = nil

        var uiAlert: UIAlertAction {
            .init(title: title, style: style, handler: handler)
        }
    }
}

extension UIViewController {

    func showSystemAlert(_ alert: AlertModel) {
        let alertVC = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert
        )
        alert.actions
            .map(\.uiAlert)
            .forEach(alertVC.addAction(_:))
        present(alertVC, animated: true)
    }
}
