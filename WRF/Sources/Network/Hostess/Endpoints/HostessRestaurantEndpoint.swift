import Alamofire

protocol HostessRestaurantEndpointProtocol: AnyObject {
    func retrieve(id: Int) -> EndpointResponse<HostessResponse<HostessRestaurant>>
}

final class HostessRestaurantEndpoint: HostessEndpoint, HostessRestaurantEndpointProtocol {
    static let endpoint = "/restaurant"

    func retrieve(id: Int) -> EndpointResponse<HostessResponse<HostessRestaurant>> {
        let params: [String: Any] = ["restaurant_id": id]
        return self.retrieve(
            endpoint: Self.endpoint,
            parameters: params
        )
    }
}
