import Foundation
import PromiseKit

protocol EventMetaPersistenceServiceProtocol: AnyObject {
    func retrieve(by id: Event.IDType) -> Guarantee<EventContainer?>
    func save(event: EventContainer) -> Promise<Void>
}

final class EventMetaPersistenceService: RealmPersistenceService<EventContainer>, EventMetaPersistenceServiceProtocol {
    static let shared = EventMetaPersistenceService()

    func retrieve(by id: Event.IDType) -> Guarantee<EventContainer?> {
        return Guarantee<EventContainer?> { seal in
            let predicate = NSPredicate(format: "id == %@", id)
            let eventMeta = self.read(predicate: predicate).first
            seal(eventMeta)
        }
    }

    func save(event: EventContainer) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(object: event)
            seal.fulfill_()
        }
    }
}
