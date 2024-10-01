import Alamofire
import Foundation
import PromiseKit

protocol EventEndpointProtocol: AnyObject {
    func retrieve(id: Event.IDType) -> EndpointResponse<NavigatorItemResponse<Event>>
}

final class EventEndpoint: NavigatorEndpoint, EventEndpointProtocol {
    static let endpoint = "/screens/event"

    func retrieve(id: Event.IDType) -> EndpointResponse<NavigatorItemResponse<Event>> {
        let params = ["id": id]
        return self.retrieve(endpoint: EventEndpoint.endpoint, parameters: params)
    }
}
