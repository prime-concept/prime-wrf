import Alamofire
import Foundation
import PromiseKit

protocol TaxiEndpointProtocol: AnyObject {
    func calculate(start: Coordinate, end: Coordinate) -> EndpointResponse<TaxiResponse>
}

final class TaxiEndpoint: NavigatorEndpoint, TaxiEndpointProtocol {
    static let endpoint = "/taxi"

    func calculate(start: Coordinate, end: Coordinate) -> EndpointResponse<TaxiResponse> {
        let params = [
            "start_lng": start.longitude,
            "start_lat": start.latitude,
            "end_lng": end.longitude,
            "end_lat": end.latitude
        ]
        return self.retrieve(endpoint: TaxiEndpoint.endpoint, parameters: params)
    }
}
