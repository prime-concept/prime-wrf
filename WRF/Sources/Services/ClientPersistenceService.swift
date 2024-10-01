import PromiseKit

protocol ClientPersistenceServiceProtocol: AnyObject {
    func save(client: PrimePassClient)
    func retrieve() -> Guarantee<PrimePassClient?>
    func remove()
}

final class ClientPersistenceService: ClientPersistenceServiceProtocol {
	static let shared = ClientPersistenceService()
	
    private static let clientKey = "clientKey"

    private let defaults = UserDefaults.standard

    func save(client: PrimePassClient) {
        let encoded = DictionaryHelper.makeDictionary(from: client)
        self.defaults.setValue(encoded, forKey: ClientPersistenceService.clientKey)
    }

    func retrieve() -> Guarantee<PrimePassClient?> {
        return Guarantee<PrimePassClient?> { seal in
            guard let clientData = self.defaults.dictionary(forKey: ClientPersistenceService.clientKey),
                  let client: PrimePassClient = DictionaryHelper.makeObject(from: clientData) else {
                seal(nil)
                return
            }
            seal(client)
        }
    }

	var client: PrimePassClient? {
		guard let clientData = self.defaults.dictionary(forKey: ClientPersistenceService.clientKey),
			  let client: PrimePassClient = DictionaryHelper.makeObject(from: clientData) else {
			return nil
		}

		return client
	}

    func remove() {
        self.defaults.removeObject(forKey: ClientPersistenceService.clientKey)
    }
}
