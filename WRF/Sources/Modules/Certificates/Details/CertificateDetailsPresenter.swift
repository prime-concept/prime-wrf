protocol CertificatePresenterInput {
    func purchase()
    func didLoad()
}

final class CertificateDetailsPresenter: CertificatePresenterInput {
    private let viewModel: CertificateDetailsViewModel

    weak var view: CertificateDetailsViewProtocol?

    init(viewModel: CertificateDetailsViewModel) {
        self.viewModel = viewModel
    }

    func didLoad() {
		self.view?.setup(with: self.viewModel)
    }

    func purchase() {
        if case let .new(data) = viewModel.details {
            data.onPurchaseAction()
        }
    }
}
