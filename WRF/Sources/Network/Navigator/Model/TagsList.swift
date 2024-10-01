import Foundation
import PromiseKit

struct TagsList: Decodable {
    let events: [Tag]
    let restaurants: [Tag]
}
