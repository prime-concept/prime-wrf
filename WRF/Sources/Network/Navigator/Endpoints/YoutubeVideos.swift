import Alamofire
import Foundation
import PromiseKit

protocol YoutubeVideosEndpointProtocol: AnyObject {
    func retrieve() -> EndpointResponse<NavigatorListResponse<YoutubeVideo>>
}

final class YoutubeVideosEndpoint: NavigatorEndpoint, YoutubeVideosEndpointProtocol {
    static let endpoint = "/screens/youtube_videos"

    func retrieve() -> EndpointResponse<NavigatorListResponse<YoutubeVideo>> {
        return self.retrieve(endpoint: YoutubeVideosEndpoint.endpoint)
    }
}
