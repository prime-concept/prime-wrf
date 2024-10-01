import Foundation
import RealmSwift

final class RestaurantDetailContainerPersistent: Object {
    @objc dynamic var id: Restaurant.IDType = ""
    @objc dynamic var descriptionText: String?
    @objc dynamic var assessment: PrimePassAssessmentPersistent?
    @objc dynamic var phone: String?
    @objc dynamic var menu: String?
    @objc dynamic var site: String?

    let events = List<EventPersistent>()
    let tags = List<TagPersistent>()
    let reviews = List<PrimePassReviewPersistent>()
    let clients = List<PrimePassClientPersistent>()
    let previewImages360 = List<String>()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension RestaurantDetailContainer: RealmObjectConvertible {
    typealias RealmObjectType = RestaurantDetailContainerPersistent

    init(realmObject: RestaurantDetailContainerPersistent) {
        let assessment: PrimePassAssessment? = {
            guard let assessment = realmObject.assessment else {
                return nil
            }
            return PrimePassAssessment(realmObject: assessment)
        }()
        self = RestaurantDetailContainer(
            id: realmObject.id,
            description: realmObject.descriptionText,
            phone: realmObject.phone,
            menu: realmObject.menu,
            site: realmObject.site,
            assessment: assessment,
            events: realmObject.events.map(Event.init),
            tags: realmObject.tags.map(Tag.init),
            reviews: realmObject.reviews.map(PrimePassReview.init),
            previewImages360: realmObject.previewImages360.compactMap(URL.init).map(GradientImage.init)
        )
    }

    var realmObject: RestaurantDetailContainerPersistent {
        return RestaurantDetailContainerPersistent(plainObject: self)
    }
}

extension RestaurantDetailContainerPersistent {
    convenience init(plainObject: RestaurantDetailContainer) {
        self.init()
        self.id = plainObject.id
        self.descriptionText = plainObject.description
        self.phone = plainObject.phone
        self.menu = plainObject.menu
        self.site = plainObject.site
        self.events.append(objectsIn: plainObject.events.map(EventPersistent.init))
        self.tags.append(objectsIn: plainObject.tags.map(TagPersistent.init))
        self.reviews.append(objectsIn: plainObject.reviews.map(PrimePassReviewPersistent.init))
        self.previewImages360.append(
            objectsIn: plainObject.previewImages360.map { $0.image.absoluteString }
        )

        let assessmentObject: PrimePassAssessmentPersistent? = {
            guard let assessment = plainObject.assessment else {
                return nil
            }
            return PrimePassAssessmentPersistent(plainObject: assessment)
        }()
        self.assessment = assessmentObject
    }
}

