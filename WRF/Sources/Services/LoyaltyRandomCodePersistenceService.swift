import PromiseKit

protocol LoyaltyRandomCodePersistenceServiceProtocol: AnyObject {
    func save(randomCode: PrimePassLoyaltyRandomCodeResponse)
    func retrieve() -> Guarantee<PrimePassLoyaltyRandomCodeResponse?>
    func remove()
}

final class LoyaltyRandomCodePersistenceService: LoyaltyRandomCodePersistenceServiceProtocol {
    private static let codeKey = "randomCodeKey"

    private let defaults = UserDefaults.standard

    func save(randomCode: PrimePassLoyaltyRandomCodeResponse) {
        let encoded = DictionaryHelper.makeDictionary(from: randomCode)
        self.defaults.setValue(encoded, forKey: Self.codeKey)
    }

    func retrieve() -> Guarantee<PrimePassLoyaltyRandomCodeResponse?> {
        return Guarantee<PrimePassLoyaltyRandomCodeResponse?> { seal in
            guard let data = self.defaults.dictionary(forKey: Self.codeKey),
                  let code: PrimePassLoyaltyRandomCodeResponse = DictionaryHelper.makeObject(from: data) else {
                seal(nil)
                return
            }
            seal(code)
        }
    }

    func remove() {
        self.defaults.removeObject(forKey: Self.codeKey)
    }
}
