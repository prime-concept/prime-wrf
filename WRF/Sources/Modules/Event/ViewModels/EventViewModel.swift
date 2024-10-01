import Foundation

struct EventViewModel {
    let title: String
    let description: String?
    let bookingText: String?
    let isFavorite: Bool
    let date: String?
    let imageURL: URL?
    let participants: [Participant]
    let bookingLink: String?
    let buttonTitle: String?

    struct Participant {
        let id: String
        let title: String
        let address: String
        let isFavorite: Bool
        let imageURL: URL?
        let logoURL: URL?
        let distanceText: String?
        let price: String?
        let rating: Int
        let assessmentsCountText: String
    }
}
