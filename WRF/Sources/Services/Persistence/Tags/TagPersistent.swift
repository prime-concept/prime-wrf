import Foundation
import RealmSwift

final class TagPersistent: Object {
    @objc dynamic var id: Tag.IDType = ""
    @objc dynamic var title: String = ""
    @objc dynamic var count: Int = 0
    var images = List<String>()

    override class func primaryKey() -> String? {
        return "id"
    }
}

extension Tag: RealmObjectConvertible {
    typealias RealmObjectType = TagPersistent

    init(realmObject: TagPersistent) {
        self = Tag(
            id: realmObject.id,
            title: realmObject.title,
            images: realmObject.images.compactMap(URL.init).map(GradientImage.init),
            count: realmObject.count
        )
    }

    var realmObject: TagPersistent {
        return TagPersistent(plainObject: self)
    }
}

extension TagPersistent {
    convenience init(plainObject: Tag) {
        self.init()
        self.id = plainObject.id
        self.title = plainObject.title
        self.count = plainObject.count ?? 0
        self.images.append(objectsIn: plainObject.images?.map { $0.image.absoluteString } ?? [])
    }
}
