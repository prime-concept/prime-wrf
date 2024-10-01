import UIKit

final class CertificatesAssembly: Assembly {
	private let viewModel: CertificatesViewModel

	init(viewModel: CertificatesViewModel) {
		self.viewModel = viewModel
	}

	func makeModule() -> UIViewController {
		let presenter = CertificatesPresenter()

		let viewController = CertificatesTabbedViewController(
			presenter: presenter
		)

		presenter.viewController = viewController
		viewController.update(with: self.viewModel)

		return viewController
	}
}

