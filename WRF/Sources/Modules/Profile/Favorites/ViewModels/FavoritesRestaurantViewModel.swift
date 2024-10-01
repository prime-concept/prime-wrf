import Foundation

struct FavoritesRestaurantViewModel {
    typealias IDType = Restaurant.IDType

    let id: IDType
    let title: String
    let address: String
    let description: String?
    let distanceText: String?
    let price: String?
    let rating: Int
    let assessmentsCountText: String
    let coordinate: Coordinate?
    let isFavorite: Bool
    let imageURL: URL?
    let logoURL: URL?
    let type: FavoriteType = .restaurants
}
