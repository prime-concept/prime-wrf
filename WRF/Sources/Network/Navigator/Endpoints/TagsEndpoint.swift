import Alamofire
import Foundation
import PromiseKit

protocol TagsEndpointProtocol: AnyObject {
    func retrieve() -> EndpointResponse<TagsList>
}

final class TagsEndpoint: NavigatorEndpoint, TagsEndpointProtocol {
    static let endpoint = "/screens/tags"

    func retrieve() -> EndpointResponse<TagsList> {
        return self.retrieve(endpoint: TagsEndpoint.endpoint)
    }
}
