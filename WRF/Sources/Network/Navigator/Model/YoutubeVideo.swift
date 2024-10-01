import Foundation

// swiftlint:disable discouraged_optional_collection
struct YoutubeVideo: Decodable {
    typealias IDType = String

    let id: IDType
    let title: String?
    let author: String?
    let link: String
    let images: [GradientImage]?
}
