import Foundation
import PromiseKit

protocol RestaurantsPersistenceServiceProtocol: AnyObject {
    func retrieve() -> Guarantee<[Restaurant]>
    func retrieve(by id: Restaurant.IDType) -> Guarantee<Restaurant?>
    func retrieveBy(tagID: Tag.IDType) -> Guarantee<[Restaurant]>
    func save(restaurants: [Restaurant]) -> Promise<Void>
    func save(restaurant: Restaurant) -> Promise<Void>
}

final class RestaurantsPersistenceService: RealmPersistenceService<Restaurant>, RestaurantsPersistenceServiceProtocol {
    static let shared = RestaurantsPersistenceService(TagContainerPersistenceService.shared)

    private let restaurantContainerPersistenceService: TagContainerPersistenceServiceProtocol

    private init(_ restaurantContainerPersistenceService: TagContainerPersistenceServiceProtocol) {
        self.restaurantContainerPersistenceService = restaurantContainerPersistenceService
        super.init()
    }

    func retrieve() -> Guarantee<[Restaurant]> {
        return Guarantee<[Restaurant]> { seal in
            let restaurants = self.read()
            seal(restaurants)
        }
    }

    func retrieve(by id: Restaurant.IDType) -> Guarantee<Restaurant?> {
        return Guarantee<Restaurant?> { seal in
            let predicate = NSPredicate(format: "id == %@", id)
            let restaurant = self.read(predicate: predicate).first
            seal(restaurant)
        }
    }

    func retrieveBy(tagID: Tag.IDType) -> Guarantee<[Restaurant]> {
        return self.restaurantContainerPersistenceService.retrieve(by: tagID)
            .then { restaurantIDs -> Guarantee<[Restaurant]> in
                Guarantee<[Restaurant]> { seal in
                    let predicate = NSPredicate(format: "id IN %@", restaurantIDs)
                    let restaurants = self.read(predicate: predicate)
                    seal(restaurants)
                }
            }
    }

    func save(restaurants: [Restaurant]) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(objects: restaurants)
            seal.fulfill_()
        }
    }

    func save(restaurant: Restaurant) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(object: restaurant)
            seal.fulfill_()
        }
    }
}
