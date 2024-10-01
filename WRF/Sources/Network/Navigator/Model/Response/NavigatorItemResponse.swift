import Foundation

struct NavigatorItemResponse<T: Decodable>: Decodable {
    let item: T
    let dependencies: NavigatorDependenciesList

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.item = try container.decode(T.self, forKey: .item)
        self.dependencies = try NavigatorDependenciesList(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case item
    }
}
