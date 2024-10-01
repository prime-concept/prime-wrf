import Alamofire
import CoreLocation
import Foundation

class NavigatorEndpoint: APIEndpoint {
    init() {
        super.init(
            basePath: PGCMain.shared.config.navigatorBasePath,
            requestAdapter: NavigatorRequestAdapter(authService: AuthService())
        )
    }

    func makeLocationHeaders(coordinate: CLLocationCoordinate2D) -> HTTPHeaders {
        return [
            "X-User-Latitude": "\(coordinate.latitude)",
            "X-User-Longitude": "\(coordinate.longitude)"
        ]
    }
}

private class NavigatorRequestAdapter: RequestAdapter {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        urlRequest.setValue(PGCMain.shared.config.navigatorAppToken, forHTTPHeaderField: "x-app-token")

        if self.authService.isAuthorized, let userID = self.authService.authorizationData?.userID {
            urlRequest.setValue("Bearer \(userID)", forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}
