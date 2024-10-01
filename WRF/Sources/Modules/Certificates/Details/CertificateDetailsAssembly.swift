import UIKit

final class CertificateDetailsAssembly: Assembly {
	enum DetailsType {
		case new
		case my
		case old
	}

	private let type: DetailsType
    private let viewModel: SingleCertificateViewModel
	private let action: () -> Void

	private static let pointsNumberFormatter = with(NumberFormatter()) { numberFormatter in
		numberFormatter.usesGroupingSeparator = true
		numberFormatter.groupingSeparator = " "
		numberFormatter.groupingSize = 3
	}

	init(
		type: DetailsType,
		certificate viewModel: SingleCertificateViewModel,
		action: @escaping () -> Void = {}
	) {
		self.type = type
        self.viewModel = viewModel
		self.action = action
    }

    func makeModule() -> UIViewController {
		var validTo = ""

		if let activeDays = self.viewModel.activeDays {
			validTo = " – \(activeDays) с момента покупки"
		} else if let endDate = self.viewModel.endDate {
			validTo = " до \(endDate.string("dd.MM.YYYY"))"
		}

		let details: CertificateDetailsViewModel.Details
		switch self.type {
			case .new:
				details = .new(
					.init(
					 price: "баллов".pluralized("%d %@", self.viewModel.price.asIntOrZero, Self.pointsNumberFormatter),
					 purchaseDetails1: "Будет списано с вашего счета",
					 purchaseDetails2: "Срок действия сертификата" + validTo,
					 purchaseActionTitle: "Приобрести сервис",
					 onPurchaseAction: self.action
				 )
			 )
			case .my:
				details = .my(
					.init(
						title: "Используйте этот код\nдля получения услуги",
						code: self.viewModel.code ?? "",
						expiration: "Срок действия до " + validTo
					)
				)
			case .old:
				details = .old(
					.init(
						title: "Срок действия сертификата истек",
						code: self.viewModel.code ?? ""
					)
				)
		}

		let viewModel = CertificateDetailsViewModel(
			header: .init(
				title: self.viewModel.title,
				iconURL: self.viewModel.iconURL,
				description: self.viewModel.description
			),
			details: details
		)

        let presenter = CertificateDetailsPresenter(viewModel: viewModel)

        let controller = CertificateDetailsViewController(presenter: presenter)
        presenter.view = controller
        return controller
    }
}
