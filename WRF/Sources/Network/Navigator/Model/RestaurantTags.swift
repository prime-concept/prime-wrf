import Foundation

struct RestaurantTags: Decodable {
    let special: [Tag]
    let cuisines: [Tag]
    let restServices: [Tag]

    enum CodingKeys: String, CodingKey {
        case special
        case cuisines
        case restServices = "rest_services"
    }
}
