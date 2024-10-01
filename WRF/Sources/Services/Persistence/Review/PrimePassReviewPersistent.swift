import Foundation
import RealmSwift

final class PrimePassReviewPersistent: Object {
    // Int? is not available in Obj-C, so using default -1 value
    @objc dynamic var userID: PrimePassClient.IDType = -1
    @objc dynamic var place: PrimePassRestaurantIDType = ""
    @objc dynamic var review: String?
    @objc dynamic var clientName: String?
    @objc dynamic var clientSurname: String?
    @objc dynamic var avatar: String?
    @objc dynamic var publish: Bool = false
    @objc dynamic var assessment: Int = 0
    @objc dynamic var timeKey = Date()
}

extension PrimePassReview: RealmObjectConvertible {
    typealias RealmObjectType = PrimePassReviewPersistent

    init(realmObject: PrimePassReviewPersistent) {
        self = PrimePassReview(
            userID: realmObject.userID == -1 ? nil : realmObject.userID,
            place: realmObject.place,
            review: realmObject.review,
            clientName: realmObject.clientName,
            clientSurname: realmObject.clientSurname,
            avatar: realmObject.avatar,
            publish: realmObject.publish,
            assessment: realmObject.assessment,
            timeKey: realmObject.timeKey
        )
    }

    var realmObject: PrimePassReviewPersistent {
        return PrimePassReviewPersistent(plainObject: self)
    }
}

extension PrimePassReviewPersistent {
    convenience init(plainObject: PrimePassReview) {
        self.init()
        self.userID = plainObject.userID ?? -1
        self.place = plainObject.place
        self.clientName = plainObject.clientName
        self.clientSurname = plainObject.clientSurname
        self.avatar = plainObject.avatar
        self.review = plainObject.review
        self.publish = plainObject.publish
        self.assessment = plainObject.assessment
        self.timeKey = plainObject.timeKey
    }
}
