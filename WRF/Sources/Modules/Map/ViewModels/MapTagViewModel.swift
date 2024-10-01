import Foundation
import MapKit

struct MapTagViewModel {
    typealias IDType = Int

    let id: IDType
    let title: String
    let imageURL: URL?
    let count: Int
}
