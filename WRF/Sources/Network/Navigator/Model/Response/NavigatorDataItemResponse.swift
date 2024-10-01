import Foundation
import PromiseKit

struct NavigatorDataItemResponse<T: Decodable>: Decodable {
    let data: T

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.data = try container.decode(T.self, forKey: .data)
    }

    enum CodingKeys: String, CodingKey {
        case data
    }
}
