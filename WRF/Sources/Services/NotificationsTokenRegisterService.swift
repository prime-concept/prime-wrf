import Foundation
import PromiseKit

typealias TokenType = String

protocol NotificationsTokenRegisterServiceProtocol: AnyObject {
    func update(token: TokenType)
    func update(userID: PrimePassClient.IDType)
}

final class NotificationsTokenRegisterService: NotificationsTokenRegisterServiceProtocol {
    static let shared = NotificationsTokenRegisterService(endpoint: PrimePassNotifyEndpoint())

    private var token: TokenType? {
        didSet {
            self.updateRemoteToken()
        }
    }

    private var userID: PrimePassClient.IDType? {
        didSet {
            self.updateRemoteToken()
        }
    }

    private var endpoint: PrimePassNotifyEndpointProtocol

    private init(endpoint: PrimePassNotifyEndpointProtocol) {
        self.endpoint = endpoint
    }

    func update(token: TokenType) {
        self.token = token
    }

    func update(userID: PrimePassClient.IDType) {
        self.userID = userID
    }

    private func updateRemoteToken() {
        guard let token = self.token, let userID = self.userID else {
            return
        }

        let request = PrimePassNotifyTargetsRequest(userID: userID, destination: "\(token)", channel: .firebase)
        DispatchQueue.global(qos: .userInitiated).promise {
            self.endpoint.createTarget(request: request).result
        }.done { _ in
            print("notification token registration done, userID = \(userID), token = \(token)")
        }.catch { error in
            print("notification token registration failed, error = \(error)")
        }
    }
}
