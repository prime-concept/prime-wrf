import Alamofire
import Foundation
import PromiseKit

protocol PrimePassClientEndpointProtocol: AnyObject {
    func create(
        request: PrimePassClientCreateRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassClientCreateResponse>>
    func retrieve(id: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassClient>>
    func retrieveCard(id: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassCard>>
    func update(client: PrimePassClient) -> EndpointResponse<PrimePassResponse<PrimePassClientUpdateResponse>>
    func delete(id: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassClientUpdateResponse>>
}

final class PrimePassClientEndpoint: PrimePassEndpoint, PrimePassClientEndpointProtocol {
    static let endpoint = "/v1/crm/client"

    init() {
        super.init(shouldUseContractor: true)
    }

    func create(
        request: PrimePassClientCreateRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassClientCreateResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(endpoint: PrimePassClientEndpoint.endpoint, parameters: parameters)
    }

    func retrieve(id: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassClient>> {
        let parameters = ["user_id": id]
        return self.retrieve(endpoint: PrimePassClientEndpoint.endpoint, parameters: parameters)
    }

    func retrieveCard(id: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassCard>> {
        let parameters = ["user_id": id]
        return self.retrieve(endpoint: PrimePassClientEndpoint.endpoint, parameters: parameters)
    }

    func update(client: PrimePassClient) -> EndpointResponse<PrimePassResponse<PrimePassClientUpdateResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: client)
        return self.update(endpoint: PrimePassClientEndpoint.endpoint, parameters: parameters)
    }

    func delete(id: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassClientUpdateResponse>> {
        let parameters = ["user_id": id]
        return remove(
            endpoint: Self.endpoint + "/delete/personal",
            parameters: parameters,
            encoding: URLEncoding.default
        )
    }
}
