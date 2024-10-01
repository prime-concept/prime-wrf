import UIKit

struct CertificatesNavigationViewModel {
	let cardImageURLs: [URL]
	let count: String

	let onTap: () -> Void
}

struct SingleCertificateViewModel {
	init(
		id: String,
		title: String,
		iconURL: URL?,
		description: String,
		price: String? = nil,
		priceIcon: UIImage? = nil,
		code: String? = nil,
		endDate: Date?,
		activeDays: String?,
		actionIcon: UIImage
	) {
		self.id = id
		self.iconURL = iconURL
		self.title = title
		self.description = description
		self.price = price
		self.priceIcon = priceIcon
		self.code = code
		self.endDate = endDate
		self.activeDays = activeDays
		self.actionIcon = actionIcon
	}

	let id: String

	let iconURL: URL?
	let title: String
	let description: String
	let endDate: Date?
	let activeDays: String?

	let price: String?
	let priceIcon: UIImage?

	let actionIcon: UIImage

	let code: String?
}

struct CertificatesViewModel {
	struct Tab {
		let title: String
		let certificates: [SingleCertificateViewModel]
		let noDataHint: String
	}

	let new: Tab
	let my: Tab
	let old: Tab
	
	let pointsAvailable: String
}

struct CertificateDetailsViewModel {
	let header: Header?
	let details: Details

	struct Header {
		let title: String
		let iconURL: URL?
		let description: String
	}

	enum Details {
		case new(_ data: Purchase)
		case my(_ data: Usage)
		case old(_ data: Expiration)
		case notification(_ data: Notification)
	}

	struct Purchase {
		let price: String
		let purchaseDetails1: String
		let purchaseDetails2: String

		var isLoading = false

		let purchaseActionTitle: String
		let onPurchaseAction: () -> Void
	}

	struct Usage {
		let title: String
		let code: String
		let expiration: String
	}

	struct Expiration {
		let title: String
		let code: String
	}

	struct Notification {
		let icon: UIImage?
		let text: String?

		let actionTitle: String?
		let action: (() -> Void)?
	}
}
