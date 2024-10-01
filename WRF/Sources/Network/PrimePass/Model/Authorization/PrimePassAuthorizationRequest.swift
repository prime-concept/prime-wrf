import Foundation

struct PrimePassAuthorizationRequest: Codable {
    let login: String
    let password: String?
    let authorizationType: PrimePassAuthorizationType

    enum CodingKeys: String, CodingKey {
        case login
        case password
        case authorizationType = "authorization_type"
    }
}
