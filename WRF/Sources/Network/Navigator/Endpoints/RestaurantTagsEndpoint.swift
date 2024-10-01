import Alamofire
import CoreLocation
import Foundation
import PromiseKit

protocol RestaurantTagsEndpointProtocol: AnyObject {
    func retrieve() -> EndpointResponse<RestaurantTags>
}

final class RestaurantTagsEndpoint: NavigatorEndpoint, RestaurantTagsEndpointProtocol {
    static let endpoint = "/screens/tags_restaurants"

    func retrieve() -> EndpointResponse<RestaurantTags> {
        return self.retrieve(endpoint: RestaurantTagsEndpoint.endpoint)
    }
}
