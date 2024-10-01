import Foundation
import RealmSwift

final class PrimePassAssessmentPersistent: Object {
    @objc dynamic var rating: Float = 0
    @objc dynamic var number: Int = 0
    @objc dynamic var place: PrimePassRestaurantIDType = ""

    override class func primaryKey() -> String? {
        return "place"
    }
}

extension PrimePassAssessment: RealmObjectConvertible {
    typealias RealmObjectType = PrimePassAssessmentPersistent

    init(realmObject: PrimePassAssessmentPersistent) {
        self = PrimePassAssessment(
            rating: realmObject.rating,
            number: realmObject.number,
            place: realmObject.place
        )
    }

    var realmObject: PrimePassAssessmentPersistent {
        return PrimePassAssessmentPersistent(plainObject: self)
    }
}

extension PrimePassAssessmentPersistent {
    convenience init(plainObject: PrimePassAssessment) {
        self.init()
        self.rating = plainObject.rating
        self.number = plainObject.number
        self.place = plainObject.place
    }
}
