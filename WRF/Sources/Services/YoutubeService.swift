import Alamofire
import Foundation
import PromiseKit

protocol YoutubeServiceProtocol: AnyObject {
    func loadVideos(ids: [String]) -> Guarantee<YoutubeAPIVideoResponse?>
}

struct YoutubeAPIVideoResponse: Decodable {
    let items: [YoutubeAPIVideo]
}

struct YoutubeAPIVideo: Decodable {
    let id: String
    let snippet: Snippet

    struct Snippet: Decodable {
        let title: String
        let channelTitle: String
        let liveBroadcastContent: LiveState
        let thumbnails: Thumbnail

        struct Thumbnail: Decodable {
            let `default`: Description?
            let medium: Description?
            let high: Description?

            struct Description: Decodable {
                let url: URL
            }

            var highestQuality: Description? {
                return self.high ?? self.medium ?? self.default
            }
        }
    }

    enum LiveState: String, Decodable {
        case noneLive = "none"
        case live
        case upcoming
    }
}

final class YoutubeService: YoutubeServiceProtocol {
    private lazy var manager = SessionManager(configuration: self.sessionConfiguration)

    private lazy var sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15

        return configuration
    }()

    func loadVideos(ids: [String]) -> Guarantee<YoutubeAPIVideoResponse?> {
        return Guarantee { seal in
            if ids.isEmpty {
                seal(nil)
                return
            }

            let params: [String: String] = [
                "key": PGCMain.shared.config.youtubeAPIKey,
                "part": "snippet",
                "id": ids.joined(separator: ",")
            ]

            self.manager.request(
                "https://www.googleapis.com/youtube/v3/videos",
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
                headers: nil
            ).responseData { response in
                switch response.result {
                case .failure(let error):
                    print("youtube api request failed: \(error)")

                    seal(nil)
                case .success(let data):
                    let jsonDecoder = JSONDecoder()
                    if let apiResponse = try? jsonDecoder.decode(YoutubeAPIVideoResponse.self, from: data) {
                        seal(apiResponse)
                    } else {
                        seal(nil)
                    }
                }
            }
        }
    }
}
