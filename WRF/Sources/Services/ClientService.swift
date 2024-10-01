import Foundation
import PromiseKit

protocol ClientServiceProtocol {
    func update(client parameters: ClientUpdateParameters)

    func save(client: PrimePassClient)
    func saveRandomCode(_ randomCode: PrimePassLoyaltyRandomCodeResponse)
    func retrieve() -> Guarantee<PrimePassClient?>
    func retrieveRandomCode() -> Guarantee<PrimePassLoyaltyRandomCodeResponse?>
    func removeClient()
    func removeRandomCode()
    func delete(id: PrimePassClient.IDType, completion: @escaping (Bool) -> Void)
}

struct ClientUpdateParameters {
    let name: String
    let surname: String
    let phone: String
    let photo: String
    let email: String?
    let birthday: String?
    let gender: Gender?
}

/*
    ClientService is a singleton,
    so that client update is executed on background without any links to the caller environment
    to prevent 'promise deallocated' error
 */
final class ClientService: ClientServiceProtocol {
    static let shared = ClientService(
        clientEndpoint: PrimePassClientEndpoint(),
        clientPersistenceService: ClientPersistenceService(),
        randomCodePersistenceService: LoyaltyRandomCodePersistenceService(),
        authService: AuthService()
    )

    private let clientEndpoint: PrimePassClientEndpointProtocol
    private let clientPersistenceService: ClientPersistenceServiceProtocol
    private let randomCodePersistenceService: LoyaltyRandomCodePersistenceServiceProtocol
    private let authService: AuthServiceProtocol

    private init(
        clientEndpoint: PrimePassClientEndpointProtocol,
        clientPersistenceService: ClientPersistenceServiceProtocol,
        randomCodePersistenceService: LoyaltyRandomCodePersistenceServiceProtocol,
        authService: AuthServiceProtocol
    ) {
        self.clientEndpoint = clientEndpoint
        self.clientPersistenceService = clientPersistenceService
        self.randomCodePersistenceService = randomCodePersistenceService
        self.authService = authService
    }

    func update(client parameters: ClientUpdateParameters) {
        guard self.authService.isAuthorized else {
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.clientPersistenceService.retrieve()
        }.compactMap { $0 }
        .map(on: queue) { savedClient in
            savedClient.copyWithUpdatingParameters(
                name: parameters.name,
                surname: parameters.surname,
                phone: parameters.phone,
                photo: parameters.photo,
                email: parameters.email,
                birthday: parameters.birthday,
                gender: parameters.gender
            )
        }.then(on: queue) { client in
            self.clientEndpoint.update(client: client).result.map { ($0, client) }
        }.done(on: queue) { response, client in
            switch response.status {
            case .ok:
                self.save(client: client)

                NotificationCenter.default.post(name: .clientUpdated, object: nil)
            case .error:
                print("client service: error updating client - \(String(describing: response.error?.message))")
            default:
                return
            }
        }.catch { error in
            print("client service: error updating client = \(String(describing: error))")
        }
    }

    func save(client: PrimePassClient) {
        self.clientPersistenceService.save(client: client)
    }

    func delete(id: PrimePassClient.IDType, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.clientEndpoint.delete(id: id).result
        }.done { _ in
            completion(true)
        }.catch { _ in
            completion(false)
        }
    }

    func retrieve() -> Guarantee<PrimePassClient?> {
        return self.clientPersistenceService.retrieve()
    }

    func removeClient() {
        self.clientPersistenceService.remove()
    }

    // MARK: - Random code

    func saveRandomCode(_ randomCode: PrimePassLoyaltyRandomCodeResponse) {
        self.randomCodePersistenceService.save(randomCode: randomCode)
    }

    func retrieveRandomCode() -> Guarantee<PrimePassLoyaltyRandomCodeResponse?> {
        self.randomCodePersistenceService.retrieve()
    }

    func removeRandomCode() {
        self.randomCodePersistenceService.remove()
    }
}
