import Alamofire
import CoreLocation
import Foundation
import PromiseKit

protocol RestaurantEndpointProtocol: AnyObject {
    func retrieve(id: Restaurant.IDType) -> EndpointResponse<NavigatorItemResponse<Restaurant>>
}

final class RestaurantEndpoint: NavigatorEndpoint, RestaurantEndpointProtocol {
    static let endpoint = "/screens/restaurant"

    func retrieve(id: Restaurant.IDType) -> EndpointResponse<NavigatorItemResponse<Restaurant>> {
        let params = ["id": id]
        return self.retrieve(endpoint: RestaurantEndpoint.endpoint, parameters: params)
    }
}
