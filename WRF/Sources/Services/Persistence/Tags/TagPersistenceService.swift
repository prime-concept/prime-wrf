import Foundation
import PromiseKit

protocol TagPersistenceServiceProtocol: AnyObject {
    func retrieve() -> Guarantee<[Tag]>
    func save(tags: [Tag]) -> Promise<Void>
}

final class TagPersistenceService: RealmPersistenceService<Tag>, TagPersistenceServiceProtocol {
    static let shared = TagPersistenceService()

    func retrieve() -> Guarantee<[Tag]> {
        return Guarantee<[Tag]> { seal in
            let tags = self.read()
            seal(tags)
        }
    }

    func save(tags: [Tag]) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(objects: tags)
            seal.fulfill_()
        }
    }
}
