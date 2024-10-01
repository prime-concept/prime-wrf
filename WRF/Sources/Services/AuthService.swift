import Foundation

typealias AuthorizationData = (userID: Int, token: String, hostessToken: String)

protocol AuthServiceProtocol: AnyObject {
    var authorizationData: AuthorizationData? { get }
    var isAuthorized: Bool { get }

    func saveAuthorization(data: AuthorizationData)
    func removeAuthorization()
}

final class AuthService: AuthServiceProtocol {
	static let shared = AuthService()
	
    private let defaults = UserDefaults.standard

    var authorizationData: AuthorizationData? {
        guard let userID = self.defaults.object(forKey: DefaultsKey.userID.rawValue) as? Int,
              let token = self.defaults.object(forKey: DefaultsKey.token.rawValue) as? String,
              let hostessToken = self.defaults.object(forKey: DefaultsKey.hostessToken.rawValue) as? String else {
            return nil
        }

        return (userID, token, hostessToken)
    }

    var isAuthorized: Bool {
        return self.authorizationData != nil
    }

    func saveAuthorization(data: AuthorizationData) {
        self.defaults.set(data.userID, forKey: DefaultsKey.userID.rawValue)
        self.defaults.set(data.token, forKey: DefaultsKey.token.rawValue)
        self.defaults.set(data.hostessToken, forKey: DefaultsKey.hostessToken.rawValue)
    }

    func removeAuthorization() {
        self.defaults.removeObject(forKey: DefaultsKey.userID.rawValue)
        self.defaults.removeObject(forKey: DefaultsKey.token.rawValue)
        self.defaults.removeObject(forKey: DefaultsKey.hostessToken.rawValue)
    }

    private enum DefaultsKey: String {
        case userID = "authorizationUserID"
        case token = "authorizationToken"
        case hostessToken = "hostessToken"
    }
}
