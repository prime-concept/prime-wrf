import Alamofire
import Foundation
import PromiseKit

protocol BeaconsEndpointProtocol: AnyObject {
    func retrieve() -> EndpointResponse<NavigatorListResponse<BeaconItem>>
}

final class BeaconsEndpoint: NavigatorEndpoint, BeaconsEndpointProtocol {
    static let endpoint = "/screens/beacons"

    func retrieve() -> EndpointResponse<NavigatorListResponse<BeaconItem>> {
        return self.retrieve(endpoint: BeaconsEndpoint.endpoint)
    }
}
