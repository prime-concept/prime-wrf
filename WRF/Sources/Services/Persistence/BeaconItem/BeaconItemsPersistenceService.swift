import Foundation
import PromiseKit

protocol BeaconItemsPersistenceServiceProtocol: AnyObject {
    func retrieve(by regionID: String) -> Guarantee<BeaconItem?>
    func save(item: BeaconItem) -> Promise<Void>
}

final class BeaconItemsPersistenceService: RealmPersistenceService<BeaconItem>, BeaconItemsPersistenceServiceProtocol {
    static let shared = BeaconItemsPersistenceService()

    func retrieve(by regionID: String) -> Guarantee<BeaconItem?> {
        return Guarantee<BeaconItem?> { seal in
            let predicate = NSPredicate(format: "regionID == %@", regionID)
            let item = self.read(predicate: predicate).first
            seal(item)
        }
    }


    func save(item: BeaconItem) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(object: item)
            seal.fulfill_()
        }
    }
}
