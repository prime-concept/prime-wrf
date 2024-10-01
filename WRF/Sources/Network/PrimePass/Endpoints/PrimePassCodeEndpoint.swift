import Alamofire
import Foundation
import PromiseKit

protocol PrimePassCodeEndpointProtocol: AnyObject {
    func send(request: PrimePassCodeRequest) -> EndpointResponse<PrimePassResponse<String>>
}

final class PrimePassCodeEndpoint: PrimePassEndpoint, PrimePassCodeEndpointProtocol {
    static let endpoint = "/v1/crm/code"

    func send(request: PrimePassCodeRequest) -> EndpointResponse<PrimePassResponse<String>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(endpoint: Self.endpoint, parameters: parameters)
    }
}
