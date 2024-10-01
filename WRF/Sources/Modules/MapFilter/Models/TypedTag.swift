import Foundation

enum TagType: String, Encodable, CaseIterable {
    case cuisines
    case special
    case restServices = "rest_services"
}

struct TypedTag: Comparable {
    static func < (lhs: TypedTag, rhs: TypedTag) -> Bool {
        return false
    }

    static func == (lhs: TypedTag, rhs: TypedTag) -> Bool {
        return lhs.tag.id == rhs.tag.id
    }

    let tag: Tag
    let type: TagType
}
