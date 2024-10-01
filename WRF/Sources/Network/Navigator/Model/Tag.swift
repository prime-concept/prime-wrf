import Foundation
import PromiseKit

struct Tag: Decodable, Equatable {
    typealias IDType = String

    let id: IDType
    let title: String
    // swiftlint:disable:next discouraged_optional_collection
    let images: [GradientImage]?
    let count: Int?
}
