import Foundation

struct HostessBookingRequest: Codable {
    let userID: PrimePassClient.IDType
    let restaurantID: PrimePassRestaurantIDType
    let date: String
    let visitTime: Int
    let guest: Int
    let deposit: Int
    let status: HostessBooking.BookingStatus
    let comment: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case restaurantID = "place_id"
        case date
        case visitTime = "visit_time"
        case guest
        case deposit
        case status
        case comment
    }
}
