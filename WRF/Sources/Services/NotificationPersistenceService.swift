import PromiseKit

protocol NotificationPersistenceServiceProtocol: AnyObject {
    func save(notifications: [PrimePassNotification])
    func retrieve() -> Guarantee<[PrimePassNotification]>
    func remove()
}

final class NotificationPersistenceService: NotificationPersistenceServiceProtocol {
    private static let notificationKey = "notificationKey"

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func save(notifications: [PrimePassNotification]) {
        if let encoded = try? self.encoder.encode(notifications) {
            self.defaults.setValue(encoded, forKey: NotificationPersistenceService.notificationKey)
        }
    }

    func retrieve() -> Guarantee<[PrimePassNotification]> {
        return Guarantee<[PrimePassNotification]> { seal in
            guard let data = self.defaults.data(forKey: NotificationPersistenceService.notificationKey),
                  let notifications = try? self.decoder.decode([PrimePassNotification].self, from: data) else {
                seal([])
                return
            }
            seal(notifications)
        }
    }

    func remove() {
        self.defaults.removeObject(forKey: NotificationPersistenceService.notificationKey)
    }
}
