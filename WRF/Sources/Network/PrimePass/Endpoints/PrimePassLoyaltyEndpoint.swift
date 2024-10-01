import Alamofire
import Foundation
import PromiseKit

protocol PrimePassLoyaltyEndpointProtocol: AnyObject {
    func retrieveRandomCode(
        cardNumber: String
    ) -> EndpointResponse<PrimePassLoyaltyRandomCodeResponse>
}

final class PrimePassLoyaltyEndpoint: PrimePassEndpoint, PrimePassLoyaltyEndpointProtocol {
    static let endpoint = "/v1/loyalty"

    func retrieveRandomCode(
        cardNumber: String
    ) -> EndpointResponse<PrimePassLoyaltyRandomCodeResponse> {
        let parameters = ["card_number": cardNumber]
        return self.retrieve(endpoint: "\(PrimePassLoyaltyEndpoint.endpoint)/card/random_code", parameters: parameters)
    }
}
