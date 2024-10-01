import Foundation

struct PrimePassNotification: Codable {
    typealias IDType = Int

    let id: IDType
    let message: String
    let time: Date
}
