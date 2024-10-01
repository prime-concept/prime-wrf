import Alamofire
import Foundation
import PromiseKit

protocol FavoritesEndpointProtocol: AnyObject {
    func retrieveEvents(page: Int) -> EndpointResponse<NavigatorListResponse<Event>>
    func retrieveRestaurants(page: Int) -> EndpointResponse<NavigatorListResponse<Restaurant>>
}

final class FavoritesEndpoint: NavigatorEndpoint, FavoritesEndpointProtocol {
    static let endpoint = "/screens/favorites"

    func retrieveEvents(page: Int) -> EndpointResponse<NavigatorListResponse<Event>> {
        let params: [String: Any] = ["page": page, "query[type]": FavoriteType.events.rawValue]
        return self.retrieve(endpoint: FavoritesEndpoint.endpoint, parameters: params)
    }

    func retrieveRestaurants(page: Int) -> EndpointResponse<NavigatorListResponse<Restaurant>> {
        let params: [String: Any] = ["page": page, "query[type]": FavoriteType.restaurants.rawValue]
        return self.retrieve(endpoint: FavoritesEndpoint.endpoint, parameters: params)
    }
}
