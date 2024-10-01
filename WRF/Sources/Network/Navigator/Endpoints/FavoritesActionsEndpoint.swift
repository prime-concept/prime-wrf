import Alamofire
import Foundation
import PromiseKit

protocol FavoritesActionsEndpointProtocol: AnyObject {
    func markAsFavorite(resourceID: String, type: FavoriteType) -> EndpointResponse<FavoritesResponse>
    func removeFromFavorite(resourceID: String) -> EndpointResponse<FavoritesResponse>
}

final class FavoritesActionsEndpoint: NavigatorEndpoint, FavoritesActionsEndpointProtocol {
    static let endpoint = "/favorites"

    func markAsFavorite(resourceID: String, type: FavoriteType) -> EndpointResponse<FavoritesResponse> {
        let params: [String: Any] = ["resource": resourceID, "type": type.rawValue]
        return self.create(
            endpoint: FavoritesActionsEndpoint.endpoint,
            parameters: params,
            encoding: URLEncoding.default
        )
    }

    func removeFromFavorite(resourceID: String) -> EndpointResponse<FavoritesResponse> {
        let params = ["resource": resourceID]
        return self.remove(
            endpoint: FavoritesActionsEndpoint.endpoint,
            parameters: params,
            encoding: URLEncoding.default
        )
    }
}
