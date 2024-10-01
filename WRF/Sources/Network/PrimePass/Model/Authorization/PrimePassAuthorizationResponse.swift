import Foundation

struct PrimePassAuthorizationResponse: Decodable {
    let login: String
    let token: String?
    let userID: PrimePassClient.IDType
    let hostessToken: String?

    enum CodingKeys: String, CodingKey {
        case login
        case token
        case userID = "user_id"
        case hostessToken = "hostesToken"
    }
}
