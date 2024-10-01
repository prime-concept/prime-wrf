import Foundation
import PromiseKit

protocol EventsPersistenceServiceProtocol: AnyObject {
    func retrieve() -> Guarantee<[Event]>
    func retrieve(by id: Event.IDType) -> Guarantee<Event?>
    func save(events: [Event]) -> Promise<Void>
    func save(event: Event) -> Promise<Void>
}

final class EventsPersistenceService: RealmPersistenceService<Event>, EventsPersistenceServiceProtocol {
    static let shared = EventsPersistenceService()

    func retrieve() -> Guarantee<[Event]> {
        return Guarantee<[Event]> { seal in
            let events = self.read()
            seal(events)
        }
    }

    func retrieve(by id: Event.IDType) -> Guarantee<Event?> {
        return Guarantee<Event?> { seal in
            let predicate = NSPredicate(format: "id == %@", id)
            let event = self.read(predicate: predicate).first
            seal(event)
        }
    }

    func save(events: [Event]) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(objects: events)
            seal.fulfill_()
        }
    }

    func save(event: Event) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(object: event)
            seal.fulfill_()
        }
    }
}
