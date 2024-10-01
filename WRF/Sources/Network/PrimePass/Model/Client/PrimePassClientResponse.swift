import Foundation

struct PrimePassClientCreateResponse: Decodable {
    let clientID: PrimePassClient.IDType
    let cardNumber: String

    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case cardNumber = "card_number"
    }
}
