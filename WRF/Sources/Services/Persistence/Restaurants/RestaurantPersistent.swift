import Foundation
import RealmSwift

final class RestaurantPersistent: Object {
    @objc dynamic var id: Restaurant.IDType = ""
    @objc dynamic var title: String = ""
    @objc dynamic var descriptionText: String?
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var primePassID: PrimePassRestaurantIDType = ""
    @objc dynamic var address: String = ""
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var startTime: String?
    @objc dynamic var endTime: String?
    @objc dynamic var price: String?
    @objc dynamic var phone: String?
    @objc dynamic var site: String?
    @objc dynamic var menu: String?
    @objc dynamic var deliveryLink: String?
    @objc dynamic var isClosed: Bool = false
    @objc dynamic var canReserve: Bool = false

    var images = List<String>()
    var images360 = List<String>()
    var previewImages360 = List<String>()
    var logos = List<String>()
    var eventIDs = List<Event.IDType>()
    var tagsIDs = List<Tag.IDType>()
    var tagsRestaurantsIDs = List<Tag.IDType>()
    var restServicesIDs = List<Tag.IDType>()
    var cuisinesIDs = List<Tag.IDType>()
    var specialIDs = List<Tag.IDType>()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Restaurant: RealmObjectConvertible {
    typealias RealmObjectType = RestaurantPersistent

    init(realmObject: RestaurantPersistent) {
        let workingTime: WorkingTime? = {
            guard let startTime = realmObject.startTime,
                  let endTime = realmObject.endTime else {
                return nil
            }
            return WorkingTime(startTime: startTime, endTime: endTime)
        }()
        self = Restaurant(
            id: realmObject.id,
            title: realmObject.title,
            description: realmObject.descriptionText,
            coordinates: Coordinate(
                latitude: realmObject.latitude,
                longitude: realmObject.longitude
            ),
            eventsIDs: Array(realmObject.eventIDs),
            tagsIDs: Array(realmObject.tagsIDs),
            tagsRestaurantsIDs: Array(realmObject.tagsRestaurantsIDs),
            restServicesIDs: Array(realmObject.restServicesIDs),
            cuisinesIDs: Array(realmObject.cuisinesIDs),
            specialIDs: Array(realmObject.specialIDs),
            primePassID: realmObject.primePassID,
            address: realmObject.address,
            isFavorite: realmObject.isFavorite,
            images: realmObject.images.compactMap(URL.init).map(GradientImage.init),
            images360: realmObject.images360.compactMap(URL.init).map(GradientImage.init),
            previewImages360: realmObject.previewImages360.compactMap(URL.init).map(GradientImage.init),
            workingTime: workingTime,
            price: realmObject.price,
            phone: realmObject.phone,
            site: realmObject.site,
            menu: realmObject.menu,
            logos: realmObject.logos.compactMap(URL.init).map(GradientImage.init),
            deliveryLink: realmObject.deliveryLink,
            deliveryTime: nil,
            isClosed: realmObject.isClosed,
            canReserve: realmObject.canReserve
        )
    }

    var realmObject: RestaurantPersistent {
        return RestaurantPersistent(plainObject: self)
    }
}

extension RestaurantPersistent {
    convenience init(plainObject: Restaurant) {
        self.init()
        self.id = plainObject.id
        self.title = plainObject.title
        self.descriptionText = plainObject.description
        self.latitude = plainObject.coordinates?.latitude ?? 0
        self.longitude = plainObject.coordinates?.longitude ?? 0
        self.eventIDs.append(objectsIn: plainObject.eventsIDs ?? [])
        self.tagsIDs.append(objectsIn: plainObject.tagsIDs ?? [])
        self.tagsRestaurantsIDs.append(objectsIn: plainObject.tagsRestaurantsIDs ?? [])
        self.restServicesIDs.append(objectsIn: plainObject.restServicesIDs ?? [])
        self.cuisinesIDs.append(objectsIn: plainObject.cuisinesIDs ?? [])
        self.specialIDs.append(objectsIn: plainObject.specialIDs ?? [])
        self.primePassID = plainObject.primePassID
        self.address = plainObject.address
        self.isFavorite = plainObject.isFavorite
        self.startTime = plainObject.workingTime?.startTime
        self.endTime = plainObject.workingTime?.endTime
        self.images.append(
            objectsIn: plainObject.images.map { $0.image.absoluteString }
        )
        self.images360.append(
            objectsIn: (plainObject.images360 ?? []).map { $0.image.absoluteString }
        )
        self.previewImages360.append(
            objectsIn: (plainObject.previewImages360 ?? []).map { $0.image.absoluteString }
        )
        self.logos.append(
            objectsIn: (plainObject.logos ?? []).map { $0.image.absoluteString }
        )
        self.price = plainObject.price
        self.phone = plainObject.phone
        self.site = plainObject.site
        self.menu = plainObject.menu
        self.isClosed = plainObject.isClosed ?? false
        self.canReserve = plainObject.canReserve ?? false
    }
}
