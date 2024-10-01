import UIKit

protocol ProfileFaqDetailPresenterProtocol {
    func loadFaqDetail()
}

final class ProfileFaqDetailPresenter: ProfileFaqDetailPresenterProtocol {
    weak var viewController: ProfileFaqDetailViewControllerProtocol?

    private let model: ProfileFaqViewModel

    init(model: ProfileFaqViewModel) {
        self.model = model
    }

    // MARK: - Public API

    func loadFaqDetail() {
        self.viewController?.set(title: self.model.title, text: self.model.text)
    }
}
