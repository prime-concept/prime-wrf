import Foundation
import PromiseKit

protocol EventListContainerPersistenceServiceProtocol: AnyObject {
    func save(containers: [EventListContainer])-> Promise<Void>
    func retrieve(by id: Event.IDType)-> Guarantee<EventListContainer?>
}

final class EventListContainerPersistenceService:
RealmPersistenceService<EventListContainer>, EventListContainerPersistenceServiceProtocol {
    static let shared = EventListContainerPersistenceService()

    func retrieve(by id: Event.IDType) -> Guarantee<EventListContainer?> {
        return Guarantee { seal in
            let predicate = NSPredicate(format: "id == %@", id)
            let result = self.read(predicate: predicate).first
            seal(result)
        }
    }

    func save(containers: [EventListContainer]) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(objects: containers)
            seal.fulfill_()
        }
    }
}
