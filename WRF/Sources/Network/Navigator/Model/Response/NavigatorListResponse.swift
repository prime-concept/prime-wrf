import Foundation
import PromiseKit

struct NavigatorListResponse<T: Decodable>: Decodable {
    let items: [T]
    let pageable: Meta
    let dependencies: NavigatorDependenciesList

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.items = try container.decode([T].self, forKey: .items)
        self.pageable = try Meta(from: decoder)
        self.dependencies = try NavigatorDependenciesList(from: decoder)
    }

    enum CodingKeys: String, CodingKey {
        case items
    }
}
