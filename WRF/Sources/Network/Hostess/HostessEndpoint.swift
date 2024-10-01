import Alamofire
import Foundation

class HostessEndpoint: APIEndpoint {
    init() {
        super.init(
            basePath: PGCMain.shared.config.primePassHostessBasePath,
            requestAdapter: HostessRequestAdapter(authService: AuthService())
        )
    }
}

private class HostessRequestAdapter: RequestAdapter {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        if let hostessToken = self.authService.authorizationData?.hostessToken {
            urlRequest.setValue(hostessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}

struct HostessResponse<T: Decodable>: Decodable {
	let timestamp: String?
	let data: T?
	let errorCode: Int?
	let errorMessage: String?

	var isSuccessful: Bool {
		self.errorCode == nil
	}

	var error: String? {
		guard let code = errorCode else {
			return nil
		}

		return "HostessResponse ERROR: \(code) \(self.errorMessage ?? "")"
	}
}

struct HostessArrayResponse<T: Decodable>: Decodable {
	let timestamp: String?
	let data: [T]?
	let errorCode: Int?
	let errorMessage: String?
}
