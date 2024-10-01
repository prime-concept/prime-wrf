protocol BonusEndpointProtocol: AnyObject {
    func retrieveBonus(clientID: String) -> EndpointResponse<BonusesModelResponse>
}

final class BonusesEndpoint: PrimePassEndpoint, BonusEndpointProtocol {
    static let endpoint = "/v1/loyalty"

    func retrieveBonus(clientID: String) -> EndpointResponse<BonusesModelResponse> {
        retrieve(
            endpoint: "\(BonusesEndpoint.endpoint)/client/\(clientID)/expired"
        )
    }
}
