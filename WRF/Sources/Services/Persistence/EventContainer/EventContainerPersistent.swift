import Foundation
import RealmSwift

final class EventContainerPersistent: Object {
    @objc dynamic var id: Event.IDType = ""
    @objc dynamic var descriptionText: String?
    var participants = List<RestaurantPersistent>()
    var assessments = List<PrimePassAssessmentPersistent>()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension EventContainer: RealmObjectConvertible {
    typealias RealmObjectType = EventContainerPersistent

    init(realmObject: EventContainerPersistent) {
        self = EventContainer(
            id: realmObject.id,
            description: realmObject.descriptionText,
            participants: realmObject.participants.compactMap(Restaurant.init),
            assessments: realmObject.assessments.compactMap(PrimePassAssessment.init)
        )
    }

    var realmObject: EventContainerPersistent {
        return EventContainerPersistent(plainObject: self)
    }
}

extension EventContainerPersistent {
    convenience init(plainObject: EventContainer) {
        self.init()
        self.id = plainObject.id
        self.descriptionText = plainObject.description
        self.participants.append(
            objectsIn: plainObject.participants.compactMap(RestaurantPersistent.init)
        )
        self.assessments.append(
            objectsIn: plainObject.assessments.compactMap(PrimePassAssessmentPersistent.init)
        )
    }
}
