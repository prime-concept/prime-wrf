import Foundation
import PromiseKit

extension Notification.Name {
	static let certificatesChanged = Notification.Name("certificatesChanged")
}

protocol CertificatesPresenterProtocol {
	func didSelectNew(certificate: SingleCertificateViewModel)
	func didSelectMy(certificate: SingleCertificateViewModel)
	func didSelectOld(certificate: SingleCertificateViewModel)
}

final class CertificatesPresenter: CertificatesPresenterProtocol {
	weak var viewController: CertificatesTabbedViewController?

	private weak var detailsView: CertificateDetailsViewProtocol?

	func didSelectNew(certificate: SingleCertificateViewModel) {
		let detailsViewController = CertificateDetailsAssembly(
			type: .new,
			certificate: certificate,
			action: {
				self.purchase(certificate)
			}
		).makeModule()

		self.present(detailsViewController)
	}

	func didSelectMy(certificate: SingleCertificateViewModel) {
		let detailsViewController = CertificateDetailsAssembly(
			type: .my,
			certificate: certificate
		).makeModule()

		self.present(detailsViewController)
	}

	func didSelectOld(certificate: SingleCertificateViewModel) {
		let detailsViewController = CertificateDetailsAssembly(
			type: .old,
			certificate: certificate
		).makeModule()

		self.present(detailsViewController)
	}

	private func purchase(_ certificate: SingleCertificateViewModel) {
		guard let client = ClientPersistenceService.shared.client else {
			return
		}

		let price = (certificate.price ?? "0").asIntOrZero

		if price > client.bonusBalance {
			self.communicateError("У вас недостаточно баллов\nдля покупки сертификата", actionTitle: "Назад")
			return
		}

		if let endDate = certificate.endDate?.down(to: .day), endDate < Date().down(to: .day) {
			let error = "К сожалению, данный сертификат уже закончился.\nПопробуйте выбрать другой доступный из списка"
			self.communicateError(error, actionTitle: "Назад")
			return
		}

		self.detailsView?.showLoading()

		DispatchQueue.global().promise {
			PrimePassCertificatesEndpoint.shared.buyCertificate(
				id: certificate.id,
				for: client.userID
			).result
		}.done(on: .main) { response in
			if let error = response.error?.message {
				self.communicateError(error, actionTitle: "Назад")
				return
			}
			self.communicateSuccess { [weak self] in
                AnalyticsReportingService.shared.didPurchaseCertificate(id: certificate.id)
				self?.viewController?.presentTab(.my)
				self?.dismiss()
			}
		}.ensure(on: .main) {
			self.detailsView?.hideLoading()

			if let details = self.detailsView, details.viewIfLoaded?.window == nil {
				self.present(details)
			}
		}.catch(on: .main) { error in
			self.communicateError { [weak self] in
				self?.purchase(certificate)
			}
		}
	}

	private func communicateSuccess(_ text: String? = nil, action : (() -> Void)? = nil) {
		let successNotice = CertificateDetailsViewModel.Notification(
			icon: UIImage(named: "certificate-success"),
			text: text ?? "Благодарим вас за покупку.\nСертификат успешно добавлен в раздел “Мои”.",
			actionTitle: "Мои сертификаты",
			action: action
		)

		let detailsViewModel = CertificateDetailsViewModel(header: nil, details: .notification(successNotice))
		self.detailsView?.setup(with: detailsViewModel)

		NotificationCenter.default.post(.certificatesChanged)
	}

	private func communicateError(
		_ text: String? = nil,
		actionTitle: String = "Попробовать еще раз",
		action: (() -> Void)? = nil
	) {
		let action = action ?? { [weak self] in
			self?.dismiss()
		}

		let errorNotice = CertificateDetailsViewModel.Notification(
			icon: UIImage(named: "certificate-failure"),
			text: text ?? "Что-то пошло не так. Проверьте подключение к интернету и попробуйте еще раз",
			actionTitle: actionTitle,
			action: action
		)

		let detailsViewModel = CertificateDetailsViewModel(header: nil, details: .notification(errorNotice))
		self.detailsView?.setup(with: detailsViewModel)
	}

	private func present(_ viewController: UIViewController) {
		viewController.modalPresentationStyle = .overFullScreen
		
		self.viewController?.present(viewController, animated: false)
		self.detailsView = viewController as? CertificateDetailsViewProtocol
	}

	private func dismiss() {
		self.detailsView?.dismiss(animated: true) {
			self.detailsView = nil
		}
	}
}
