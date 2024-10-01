import Alamofire
import Foundation
import PromiseKit

protocol BannersEndpointProtocol: AnyObject {
	func retrieve() -> EndpointResponse<NavigatorListResponse<Banner>>
}

final class BannersEndpoint: NavigatorEndpoint, BannersEndpointProtocol {
	static let endpoint = "/screens/banners"

	func retrieve() -> EndpointResponse<NavigatorListResponse<Banner>> {
		return self.retrieve(endpoint: BannersEndpoint.endpoint)
	}
}
