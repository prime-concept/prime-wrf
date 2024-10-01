import Foundation

struct EventCellViewModel {
	init(
		id: Event.IDType,
		imageURL: URL? = nil,
		date: String? = nil,
		title: String? = nil,
		subtitle: String? = nil,
		nearestRestaurant: String? = nil,
		isFavorite: Bool = false,
		sharingEnabled: Bool = false
	) {
		self.id = id
		self.imageURL = imageURL
		self.date = date
		self.title = title
		self.subtitle = subtitle
		self.nearestRestaurant = nearestRestaurant
		self.isFavorite = isFavorite
		self.sharingEnabled = sharingEnabled
	}

	let id: Event.IDType
	let imageURL: URL?
	let date: String?
	let title: String?
	let subtitle: String?
	let nearestRestaurant: String?
	let isFavorite: Bool
	let sharingEnabled: Bool
}
