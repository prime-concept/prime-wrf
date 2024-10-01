import Foundation

struct AuthViewModel {
    let action: Action

    enum Action {
		case signIn(phoneNumber: String)
		
        case signUp(
            firstName: String,
            lastName: String,
            birthday: String,
            gender: Gender?,
			email: String,
            phoneNumber: String,
			captchaToken: String?,
			deviceId: String?
        )
    }
}

enum AuthError {
    case userNotFound
    case userAlreadyExists
    case unrecognized
}
