import Foundation

struct FavoritesResponse: Decodable {
    let type: FavoriteType

    enum CodingKeys: String, CodingKey {
        case type
    }
}