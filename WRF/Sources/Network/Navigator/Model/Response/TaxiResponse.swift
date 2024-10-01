import Foundation

struct TaxiResponse: Decodable {
    struct Partner: Decodable {
        let currency: String
        let partner: String
        let price: UInt32
        let url: String
    }

    let partners: [Partner]
}
