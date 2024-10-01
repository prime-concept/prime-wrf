import Alamofire
import Foundation
import PromiseKit

protocol PrimePassAuthorizationEndpointProtocol: AnyObject {
    func retrieve(
        request: PrimePassAuthorizationRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassAuthorizationResponse>>

    func create(
        request: PrimePassAuthorizationRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassAuthorizationResponse>>
}

final class PrimePassAuthorizationEndpoint: PrimePassEndpoint, PrimePassAuthorizationEndpointProtocol {
    static let endpoint = "/v1/crm/authorization"

    init() {
        super.init(shouldUseContractor: true)
    }

    func retrieve(
        request: PrimePassAuthorizationRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassAuthorizationResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.retrieve(endpoint: PrimePassAuthorizationEndpoint.endpoint, parameters: parameters)
    }

    func create(
        request: PrimePassAuthorizationRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassAuthorizationResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(endpoint: PrimePassAuthorizationEndpoint.endpoint, parameters: parameters)
    }
}
