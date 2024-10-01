import Foundation
import MapKit

struct MapRestaurantViewModel {
    typealias IDType = Int

    let id: IDType
    let title: String
    let address: String?
    let location: CLLocationCoordinate2D?
    let distanceText: String?
    let imageURL: URL?
    let schedule: [String]
    let rating: Int
    let assessmentsCountText: String
    let price: String?
    let deliveryTime: String?
    let hasDelivery: Bool
    let isClosed: Bool
    let logoURL: URL?
}
