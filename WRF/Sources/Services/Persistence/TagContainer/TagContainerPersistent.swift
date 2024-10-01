import Foundation
import RealmSwift

final class TagContainerPersistent: Object {
    @objc dynamic var tagID: Tag.IDType = ""

    var restaurantIDs = List<Restaurant.IDType>()

    override class func primaryKey() -> String? {
        return "tagID"
    }
}

extension TagContainer: RealmObjectConvertible {
    typealias RealmObjectType = TagContainerPersistent

    init(realmObject: TagContainerPersistent) {
        self = TagContainer(
            tagID: realmObject.tagID,
            restaurantIDs: Array(realmObject.restaurantIDs)
        )
    }

    var realmObject: TagContainerPersistent {
        return TagContainerPersistent(plainObject: self)
    }
}

extension TagContainerPersistent {
    convenience init(plainObject: TagContainer) {
        self.init()
        self.tagID = plainObject.tagID
        self.restaurantIDs.append(objectsIn: plainObject.restaurantIDs)
    }
}
