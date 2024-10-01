import Foundation

struct SearchEventViewModel {
    typealias IDType = Int

    let id: IDType
    let title: String
    let description: String?
    let bookingText: String?
    let isFavorite: Bool
    let date: String?
    let restaurantTitle: String?
    let imageURL: URL?
}
