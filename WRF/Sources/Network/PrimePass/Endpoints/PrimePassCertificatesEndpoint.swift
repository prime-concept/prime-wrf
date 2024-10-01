import Alamofire
import Foundation
import PromiseKit

final class PrimePassCertificatesEndpoint: PrimePassEndpoint {
	static let newEndpoint = "/v1/crm/client/privilege"
	static let myEndpoint = "/v1/crm/client/coupons"

	static let shared = PrimePassCertificatesEndpoint()

	init() {
		super.init(shouldUseContractor: true)
	}

	func newCertificates(for userId: PrimePassClient.IDType) -> EndpointResponse<PrimePassArrayResponse<PrimePassCertificate>> {
		let parameters = ["user_id": userId]
		return self.retrieve(endpoint: Self.newEndpoint, parameters: parameters)
	}

	func myCertificates(for userId: PrimePassClient.IDType) -> EndpointResponse<PrimePassArrayResponse<PrimePassCoupon>> {
		let parameters = ["user_id": userId]
		return self.retrieve(endpoint: Self.myEndpoint, parameters: parameters)
	}

	func buyCertificate(id: String, for userId: PrimePassClient.IDType) -> EndpointResponse<PrimePassResponse<PrimePassCertificatePurchaseResponse>> {

		let endpoint = Self.newEndpoint + "?user_id=\(userId)&privilege_id=\(id)"
		let headers = HTTPHeaders(dictionaryLiteral: ("Content-Type", "application/json"))

		return self.create(
			endpoint: endpoint,
			headers: headers
		)
	}
}
