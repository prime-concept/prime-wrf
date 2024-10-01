import Foundation
import PromiseKit

extension Notification.Name {
    static let resourceFavorited = Notification.Name("resourceFavorited")
    static let resourceUnfavorited = Notification.Name("resourceUnfavorited")
}

protocol FavoritesServiceProtocol: AnyObject {
    func updateFavoritesStatus(
        resourceID: String,
        type: FavoriteType,
        isFavorite: Bool
    ) -> Promise<FavoritesResponse>
}

final class FavoritesService: FavoritesServiceProtocol {
    private let endpoint: FavoritesActionsEndpointProtocol

    static func extractRestaurantFavorite(from notification: Notification) -> Restaurant.IDType? {
        guard let resourceId = notification.userInfo?["resourceID"] as? String,
              let type = notification.userInfo?["type"] as? FavoriteType,
              type == .restaurants else {
            return nil
        }
        return resourceId
    }

    static func extractEventFavorite(from notification: Notification) -> Event.IDType? {
        guard let resourceId = notification.userInfo?["resourceID"] as? String,
              let type = notification.userInfo?["type"] as? FavoriteType,
              type == .events else {
            return nil
        }
        return resourceId
    }

    init(endpoint: FavoritesActionsEndpointProtocol) {
        self.endpoint = endpoint
    }

    // MARK: - Public API

    func updateFavoritesStatus(resourceID: String, type: FavoriteType, isFavorite: Bool) -> Promise<FavoritesResponse> {
        return Promise<FavoritesResponse> { seal in
            if isFavorite {
                self.removeFromFavorite(seal: seal, resourceID: resourceID, type: type)
            } else {
                self.markAsFavorite(seal: seal, resourceID: resourceID, type: type)
            }
        }
    }

    // MARK: - Private API

    private func markAsFavorite(seal: Resolver<FavoritesResponse>, resourceID: String, type: FavoriteType) {
        self.endpoint.markAsFavorite(resourceID: resourceID, type: type).result.done { response in
            NotificationCenter.default.post(
                name: .resourceFavorited,
                object: nil,
                userInfo: ["resourceID": resourceID, "type": type]
            )

            seal.fulfill(response)
        }.catch { error in
            seal.reject(error)
        }
    }

    private func removeFromFavorite(seal: Resolver<FavoritesResponse>, resourceID: String, type: FavoriteType) {
        self.endpoint.removeFromFavorite(resourceID: resourceID).result.done { response in
            NotificationCenter.default.post(
                name: .resourceUnfavorited,
                object: nil,
                userInfo: ["resourceID": resourceID, "type": type]
            )

            seal.fulfill(response)
        }.catch { error in
            seal.reject(error)
        }
    }
}
