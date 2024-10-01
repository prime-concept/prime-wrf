import Foundation

struct Banner: Decodable {
	struct Image: Decodable {
		let imageURL: URL

		enum CodingKeys: String, CodingKey {
			case imageURL = "image"
		}
	}

	let id: String
	let buttonTitle: String
	let link: String
    let images: [Image]

	enum CodingKeys: String, CodingKey {
		case id
		case images
		case link
		case buttonTitle = "text_button"
	}
}
