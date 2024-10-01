import Foundation
import RealmSwift

protocol RealmObjectConvertable {
    associatedtype RealmObjectType: Object

    init(realmObject: RealmObjectType)
    var realmObject: RealmObjectType { get }
}
