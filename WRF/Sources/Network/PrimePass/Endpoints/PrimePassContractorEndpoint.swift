import Alamofire
import Foundation
import PromiseKit

struct ContractorSettings: Decodable {
	let descriptor: String?
	private let captcha_enabled: Bool?

	var isCaptchaEnabled: Bool {
		self.captcha_enabled == true
	}
}

protocol PrimePassContractorEndpointProtocol: AnyObject {
	func settings() -> Promise<PrimePassResponse<ContractorSettings>>
}

final class PrimePassContractorEndpoint: PrimePassEndpoint, PrimePassContractorEndpointProtocol {
	static let endpoint = "/v1/crm/contractor"
	static let shared = PrimePassContractorEndpoint()

	init() {
		super.init(shouldUseContractor: true)
	}

	func settings() -> Promise<PrimePassResponse<ContractorSettings>> {
		let parameters = ["id": PGCMain.shared.config.primePassHeaderKey]
		return self.retrieve(endpoint: "\(Self.endpoint)/settings", parameters: parameters).result
	}
}
