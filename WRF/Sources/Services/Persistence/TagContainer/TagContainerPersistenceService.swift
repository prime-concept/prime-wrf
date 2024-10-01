import Foundation
import PromiseKit

protocol TagContainerPersistenceServiceProtocol: AnyObject {
    func save(container: TagContainer) -> Promise<Void>
    func retrieve(by tag: Tag.IDType) -> Guarantee<[Restaurant.IDType]>
}

final class TagContainerPersistenceService:
RealmPersistenceService<TagContainer>, TagContainerPersistenceServiceProtocol {
    static let shared = TagContainerPersistenceService()

    func save(container: TagContainer) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(object: container)
            seal.fulfill_()
        }
    }

    func retrieve(by tag: Tag.IDType) -> Guarantee<[Restaurant.IDType]> {
        return Guarantee<[Restaurant.IDType]> { seal in
            let predicate = NSPredicate(format: "tagID == %@", tag)
            let result = self.read(predicate: predicate).first
            seal(result?.restaurantIDs ?? [])
        }
    }
}
