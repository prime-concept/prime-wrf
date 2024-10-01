import Foundation
import RealmSwift

final class EventPersistent: Object {
    @objc dynamic var id: Event.IDType = ""
    @objc dynamic var title: String = ""
    @objc dynamic var descriptionText: String?
    @objc dynamic var bookingText: String?
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var bookingLink: String?
    @objc dynamic var buttonName: String?
    var schedule = List<Date>()
    var restaurantIDs = List<Restaurant.IDType>()
    var tagsIDs = List<Tag.IDType>()
    var images = List<String>()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Event: RealmObjectConvertible {
    typealias RealmObjectType = EventPersistent

    init(realmObject: EventPersistent) {
        self = Event(
            id: realmObject.id,
            title: realmObject.title,
            description: realmObject.descriptionText,
            bookingText: realmObject.bookingText,
            isFavorite: realmObject.isFavorite,
            schedule: Array(realmObject.schedule),
            restaurantsIDs: Array(realmObject.restaurantIDs),
            images: realmObject.images.compactMap(URL.init).map(GradientImage.init),
            partnerLink: nil,
            tagsIDs: Array(realmObject.tagsIDs),
            bookingLink: realmObject.bookingLink,
            buttonName: realmObject.buttonName
        )
    }

    var realmObject: EventPersistent {
        return EventPersistent(plainObject: self)
    }
}

extension EventPersistent {
    convenience init(plainObject: Event) {
        self.init()
        self.id = plainObject.id
        self.title = plainObject.title
        self.descriptionText = plainObject.description
        self.bookingText = plainObject.bookingText
        self.isFavorite = plainObject.isFavorite
        self.schedule.append(objectsIn: plainObject.schedule)
        self.restaurantIDs.append(objectsIn: plainObject.restaurantsIDs ?? [])
        self.tagsIDs.append(objectsIn: plainObject.tagsIDs ?? [])
        self.images.append(objectsIn: (plainObject.images ?? []).map { $0.image.absoluteString })
        self.buttonName = plainObject.buttonName
        self.bookingLink = plainObject.bookingLink
    }
}
