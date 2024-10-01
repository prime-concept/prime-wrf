import Foundation

struct AuthConfirmationViewModel {
    let password: String
}

enum AuthConfirmationError {
    case invalidCode
    case unrecognized
}
