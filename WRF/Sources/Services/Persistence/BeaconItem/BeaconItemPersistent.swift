import Foundation
import RealmSwift

final class BeaconItemPersistent: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var major: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var regionID: String = ""

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension BeaconItem: RealmObjectConvertible {
    typealias RealmObjectType = BeaconItemPersistent

    init(realmObject: BeaconItemPersistent) {
        self = BeaconItem(
            beacon: BeaconItem.Beacon(
                id: realmObject.id,
                major: realmObject.major
            ),
            notification: BeaconItem.Notification(
                title: realmObject.title,
                body: realmObject.body
            ),
            region: BeaconItem.Region(id: realmObject.regionID)
        )
    }

    var realmObject: BeaconItemPersistent {
        return BeaconItemPersistent(plainObject: self)
    }
}

extension BeaconItemPersistent {
    convenience init(plainObject: BeaconItem) {
        self.init()

        self.id = plainObject.beacon.id
        self.major = plainObject.beacon.major
        self.title = plainObject.notification.title
        self.body = plainObject.notification.body
        self.regionID = plainObject.region.id
    }
}
