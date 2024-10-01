import Foundation

struct HostessRestaurant: Codable {
    let id: Int
    let name: String
    let maxOnlineGuests: Int
    var onlineCloseAfter: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case maxOnlineGuests = "max_online_guests"
        case onlineCloseAfter = "online_close_after"
    }
}
