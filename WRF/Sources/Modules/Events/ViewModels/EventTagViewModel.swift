import Foundation

struct EventTagViewModel {
    typealias IDType = Int

    let id: IDType
    let title: String
    let imageURL: URL?
    let eventsCount: Int?
    let isSelected: Bool
}
