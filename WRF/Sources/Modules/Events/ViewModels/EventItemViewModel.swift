import Foundation

struct EventItemViewModel {
    typealias IDType = Int

    let id: IDType
    let title: String
    let isFavorite: Bool
    let date: String?
    let restaurantTitle: String?
    let imageURL: URL?
    let videoInfo: VideoInfo?

    struct VideoInfo {
        let author: String
        let videoURL: URL?
        let videoID: String
        let isLive: Bool
    }
}
