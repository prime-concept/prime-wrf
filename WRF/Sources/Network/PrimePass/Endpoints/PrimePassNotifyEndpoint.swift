import Alamofire
import Foundation
import PromiseKit

protocol PrimePassNotifyEndpointProtocol: AnyObject {
    func createTarget(
        request: PrimePassNotifyTargetsRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassNotifyTargetsResponse>>
    func retrieve(userID: Int) -> EndpointResponse<PrimePassArrayResponse<PrimePassNotification>>
}

final class PrimePassNotifyEndpoint: PrimePassEndpoint, PrimePassNotifyEndpointProtocol {
    static let endpoint = "/v1/crm/notify"

    func createTarget(
        request: PrimePassNotifyTargetsRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassNotifyTargetsResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(
            endpoint: "\(PrimePassNotifyEndpoint.endpoint)/targets",
            parameters: parameters
        )
    }

    func retrieve(userID: Int) -> EndpointResponse<PrimePassArrayResponse<PrimePassNotification>> {
        let parameters = ["user_id": userID]
        return self.retrieve(
            endpoint: "\(PrimePassNotifyEndpoint.endpoint)/messages",
            parameters: parameters
        )
    }
}
