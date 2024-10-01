import Foundation

struct FavoritesEventViewModel {
    typealias IDType = Event.IDType

    let id: IDType
    let title: String
    let description: String?
    let bookingText: String?
    let isFavorite: Bool
    let date: String?
    let nearestRestaurant: String?
    let imageURL: URL?
    let type: FavoriteType = .events
}
