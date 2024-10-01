import Alamofire
import Foundation

class PrimePassEndpoint: APIEndpoint {
    init(shouldUseContractor: Bool = false) {
        super.init(
            basePath: PGCMain.shared.config.primePassBasePath,
            requestAdapter: PrimePassRequestAdapter(
                shouldUseContractor: shouldUseContractor, authService: AuthService()
            )
        )
    }
}

private class PrimePassRequestAdapter: RequestAdapter {
    private var shouldUseContractor: Bool
    private let authService: AuthServiceProtocol

    init(shouldUseContractor: Bool, authService: AuthServiceProtocol) {
        self.shouldUseContractor = shouldUseContractor
        self.authService = authService
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest

        if self.shouldUseContractor {
            urlRequest.setValue(PGCMain.shared.config.primePassHeaderKey, forHTTPHeaderField: "Contractor-Id")
        }

        if self.authService.isAuthorized, let token = self.authService.authorizationData?.token {
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}
