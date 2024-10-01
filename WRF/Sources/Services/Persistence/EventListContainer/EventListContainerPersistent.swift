import Foundation
import RealmSwift

final class EventListContainerPersistent: Object {
    @objc dynamic var id: Event.IDType = ""
    var restaurants = List<RestaurantPersistent>()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension EventListContainer: RealmObjectConvertible {
    typealias RealmObjectType = EventListContainerPersistent

    init(realmObject: RealmObjectType) {
        self.id = realmObject.id
        self.restaurants = realmObject.restaurants.map(Restaurant.init)
    }

    var realmObject: EventListContainerPersistent {
        return EventListContainerPersistent(plainObject: self)
    }
}

extension EventListContainerPersistent {
    convenience init(plainObject: EventListContainer) {
        self.init()
        self.id = plainObject.id
        self.restaurants.append(objectsIn: plainObject.restaurants.map(RestaurantPersistent.init))
    }
}
