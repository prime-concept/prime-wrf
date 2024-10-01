import Alamofire
import Foundation
import PromiseKit

protocol SearchCitiesEndpointProtocol: AnyObject {
    func retrieve() -> EndpointResponse<SearchCitiesModel>
}

final class SearchCitiesEndpoint: NavigatorEndpoint, SearchCitiesEndpointProtocol {
    let endpoint = "/screens/cities"

    func retrieve() -> EndpointResponse<SearchCitiesModel> {
        retrieve(endpoint: endpoint)
    }
}
