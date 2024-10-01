import Foundation

struct PrimePassResponse<T: Decodable>: Decodable {
    let status: Status?
    let data: T?
    let error: PrimePassError?

    enum Status: String, Decodable {
        // swiftlint:disable:next identifier_name
        case ok = "OK"
        case error = "ERROR"
    }
}

struct PrimePassArrayResponse<T: Decodable>: Decodable {
    let status: Status
    // swiftlint:disable:next discouraged_optional_collection
    let data: [T]?
    let error: PrimePassError?

    enum Status: String, Codable {
        // swiftlint:disable:next identifier_name
        case ok = "OK"
        case error = "ERROR"
    }
}

struct PrimePassError: Decodable {
    let message: String?
    let code: Int?
}
