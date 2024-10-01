import Foundation
import MapKit

struct RestaurantViewModel {
    let title: String
    let address: String?
    let description: String?
    let distanceText: String?
    let imageURL: URL?
    let events: [Event]
    let panorama: Panorama?
    let rating: Int?
    let ratingFloat: Float?
    let assessmentsCountText: String?
    let assessmentsCount: Int?
    let reviews: [Review]
    let price: String?
    let workingTime: WorkingTime?
    let phone: String?
    let coordinate: (latitude: Double, longitude: Double)?
    // swiftlint:disable:next discouraged_optional_boolean
    var isFavorite: Bool?
    var site: String?
    var images: [GradientImage]
    var tags: [String]
    var deliveryFrameID: String?
    var canReserve: Bool
    var isClosed: Bool
    var menu: String?

    struct Event {
        let title: String
        let imageURL: URL?
        let date: String?
    }

    struct Panorama {
        let images: [(image: URL, preview: URL)]
    }

    struct Review {
        let userImage: UIImage
        let userName: String
        let dateText: String
        let rating: Int
        let text: String
    }

    struct WorkingTime {
        let days: String
        let hours: String
    }
}
