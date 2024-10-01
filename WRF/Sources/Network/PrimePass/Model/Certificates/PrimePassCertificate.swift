import Foundation

struct PrimePassCertificate: Decodable {
	internal init(
		id: Int,
		cost: Int,
		active: Bool,
		destinationType: Int,
		description: String? = nil,
		privilege_name: String,
		photo_link: String? = nil,
		date_from: String,
		date_to: String? = nil,
		active_days_after_buy: Int? = nil,
		partner_guid: String? = nil
	) {
		self.id = id
		self.cost = cost
		self.active = active
		self.destinationType = destinationType
		self.description = description
		self.privilege_name = privilege_name
		self.date_from = date_from
		self.date_to = date_to
		self.active_days_after_buy = active_days_after_buy
		self.partner_guid = partner_guid
		self.photo_link = photo_link
	}

	let id: Int
	let cost: Int
	let active: Bool
	let destinationType: Int
	let description: String?

	private let photo_link: String?
	private let privilege_name: String
	private let date_from: String
	private let date_to: String?

	private let active_days_after_buy: Int?
	private let partner_guid: String?

	var name: String {
		self.privilege_name
	}

	var startDate: Date {
		self.date_from.date("YYYY-MM-dd")!
	}

	var endDate: Date? {
		self.date_to?.date("YYYY-MM-dd")
	}

	var activeDays: String? {
		guard let days = self.active_days_after_buy else {
			return nil
		}

		return "дней".pluralized("%d %@", days)
	}

	var partnerGuid: String? {
		self.partner_guid
	}

	var iconURL: URL? {
		guard let url = self.photo_link else {
			return nil
		}

		return URL(string: url)
	}
}

struct PrimePassCoupon: Decodable {
	var id: Int { self.coupon_id }
	let code: String
	let cost: Int
	let active: Bool
	let description: String?
	private let photo_link: String?

	let time_key: String?

	private let coupon_id: Int
	private let privilege_name: String
	private let start_date: String
	private let end_date: String?
	private let privilege_photo: String?
	private let active_days_after_buy: Int?

	var name: String {
		self.privilege_name
	}

	var startDate: Date {
		self.start_date.date("YYYY-MM-dd")!
	}

	var endDate: Date? {
		self.end_date?.date("YYYY-MM-dd")
	}

	var activeDays: String? {
		guard let days = self.active_days_after_buy else {
			return nil
		}

		return "дней".pluralized("%d %@", days)
	}

	var iconURL: URL? {
		guard let url = self.photo_link else {
			return nil
		}

		return URL(string: url)
	}
}

struct PrimePassCertificatePurchaseResponse: Decodable {
	let code: String
}
