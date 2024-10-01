import Foundation
import PromiseKit

protocol RestaurantDetailPersistenceServiceProtocol: AnyObject {
    func retrieve(by id: Restaurant.IDType) -> Guarantee<RestaurantDetailContainer?>
    func save(restaurant: RestaurantDetailContainer) -> Promise<Void>
}

final class RestaurantDetailPersistenceService:
RealmPersistenceService<RestaurantDetailContainer>, RestaurantDetailPersistenceServiceProtocol {
    static let shared = RestaurantDetailPersistenceService()

    func retrieve(by id: Restaurant.IDType) -> Guarantee<RestaurantDetailContainer?> {
        return Guarantee<RestaurantDetailContainer?> { seal in
            let predicate = NSPredicate(format: "id == %@", id)
            let restaurant = self.read(predicate: predicate).first
            seal(restaurant)
        }
    }

    func save(restaurant: RestaurantDetailContainer) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(object: restaurant)
            seal.fulfill_()
        }
    }
}
