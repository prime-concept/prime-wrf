import IQKeyboardManagerSwift
import SnapKit
import UIKit

protocol FeedbackViewControllerProtocol: AnyObject {
    func dismissViewController()
}

protocol FeedbackViewDelegate: AnyObject {
    func feedbackViewDidConfirm(_ viewModel: FeedbackViewModel)
}

final class FeedbackViewController: UIViewController {
    private static let buttonDisappearAnimationDuration: TimeInterval = 0.25

    private let placeName: String

    let presenter: FeedbackPresenterProtocol
    lazy var feedbackView = self.view as? FeedbackView

    init(presenter: FeedbackPresenterProtocol, placeName: String) {
        self.presenter = presenter
        self.placeName = placeName
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = FeedbackView(frame: UIScreen.main.bounds)
        view.placeName = self.placeName
        view.delegate = self
        self.view = view
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.attachFloatingButton()
        IQKeyboardManager.shared.enable = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.dettachFloatingButton()
        IQKeyboardManager.shared.enable = false
    }

    // MARK: - Private API

    private func attachFloatingButton() {
        guard let feedbackView = self.feedbackView else {
            return
        }

        guard let window = UIApplication.shared.keyWindow else {
            return
        }

        window.addSubview(feedbackView.confirmationButton)
        feedbackView.confirmationButton.translatesAutoresizingMaskIntoConstraints = false
        feedbackView.confirmationButton.snp.makeConstraints { make in
            make.height.equalTo(feedbackView.appearance.confirmationButtonHeight)
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(window.safeAreaLayoutGuide.snp.bottom)
                    .offset(-feedbackView.appearance.confirmationButtonInsets.bottom)
            } else {
                make.bottom
                    .equalToSuperview()
                    .offset(-feedbackView.appearance.confirmationButtonInsets.bottom)
            }
            make.leading.equalToSuperview().offset(feedbackView.appearance.confirmationButtonInsets.left)
            make.trailing.equalToSuperview().offset(-feedbackView.appearance.confirmationButtonInsets.right)
        }
    }

    private func dettachFloatingButton() {
        guard let feedbackView = self.feedbackView else {
            return
        }

        UIView.animate(
            withDuration: FeedbackViewController.buttonDisappearAnimationDuration,
            animations: {
                feedbackView.confirmationButton.alpha = 0.0
            },
            completion: { _ in
                feedbackView.confirmationButton.removeFromSuperview()
            }
        )
    }
}

extension FeedbackViewController: FeedbackViewControllerProtocol {
    func dismissViewController() {
        self.fp_dismiss(animated: true)
    }
}

extension FeedbackViewController: FeedbackViewDelegate {
    func feedbackViewDidConfirm(_ viewModel: FeedbackViewModel) {
        self.presenter.createFeedback(viewModel: viewModel)
    }
}
