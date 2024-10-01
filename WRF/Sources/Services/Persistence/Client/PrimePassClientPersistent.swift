import Foundation
import RealmSwift

final class PrimePassClientPersistent: Object {
    @objc dynamic var userID: PrimePassClient.IDType = 0
    @objc dynamic var name: String?
    @objc dynamic var surname: String?
    @objc dynamic var phone: String = ""
    @objc dynamic var photo: String?
    @objc dynamic var email: String?
    @objc dynamic var gender: String?
	@objc dynamic var bonusBalance: Int = 0

    override class func primaryKey() -> String? {
        return "userID"
    }
}

extension PrimePassClient: RealmObjectConvertible {
    typealias RealmObjectType = PrimePassClientPersistent

    init(realmObject: PrimePassClientPersistent) {
        self = PrimePassClient(
            userID: realmObject.userID,
            name: realmObject.name,
            surname: realmObject.surname,
            phone: realmObject.phone,
            photo: realmObject.photo,
            email: realmObject.email,
            balance: 0,
            subscribed: false,
            deleted: false,
            gradeName: "",
            ticketGradeID: 0,
            ticketGradeName: "",
            cardNumber: "",
            nextGradeUpgradeAmount: 0,
            courseBonus: 0,
            courseRub: 0,
			bonusBalance: realmObject.bonusBalance,
            birthday: "",
            //swiftlint:disable force_unwrapping
            gender: realmObject.gender != nil ? Gender(rawValue: realmObject.gender!) : nil
        )
    }

    var realmObject: PrimePassClientPersistent {
        return PrimePassClientPersistent(plainObject: self)
    }
}

extension PrimePassClientPersistent {
    convenience init(plainObject: PrimePassClient) {
        self.init()
        self.userID = plainObject.userID
        self.name = plainObject.name
        self.surname = plainObject.surname
        self.photo = plainObject.photo
        self.email = plainObject.email
        self.gender = plainObject.gender?.rawValue
		self.bonusBalance = plainObject.bonusBalance
    }
}
