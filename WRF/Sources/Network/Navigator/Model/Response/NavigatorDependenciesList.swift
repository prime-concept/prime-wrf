import Foundation
import PromiseKit

struct NavigatorDependenciesList: Decodable {
    let events: [Event]
    let restaurants: [Restaurant]

    let restServices: [Tag]
    let cuisines: [Tag]
    let special: [Tag]

	let tags: [Tag]
	let tagsRestaurants: [Tag]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.events = (try? container.decode([Event].self, forKey: .events)) ?? []
        self.restaurants = (try? container.decode([Restaurant].self, forKey: .restaurants)) ?? []
        self.tags = (try? container.decode([Tag].self, forKey: .tags)) ?? []
        self.tagsRestaurants = (try? container.decode([Tag].self, forKey: .tagsRestaurants)) ?? []
        self.restServices = (try? container.decode([Tag].self, forKey: .restServices)) ?? []
        self.cuisines = (try? container.decode([Tag].self, forKey: .cuisines)) ?? []
        self.special = (try? container.decode([Tag].self, forKey: .special)) ?? []
    }

    enum CodingKeys: String, CodingKey {
        case events
        case restaurants
        case tags = "tags"
        case tagsRestaurants = "tags_restaurants"
        case restServices = "rest_services"
        case cuisines = "cuisines"
        case special
    }
}
