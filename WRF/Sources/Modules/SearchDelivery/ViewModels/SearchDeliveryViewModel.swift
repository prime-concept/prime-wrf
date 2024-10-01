import Foundation

struct SearchDeliveryViewModel {
    typealias IDType = Int

    let id: IDType
    let title: String
    let description: String?
    let coordinate: Coordinate?
    let imageURL: URL?
    let price: String?
    let rating: Int
    let assessmentsCountText: String
    let distance: String?
    let schedule: [String]
    let deliveryTime: String
    let hasDelivery: Bool
    let isClosed: Bool
}
