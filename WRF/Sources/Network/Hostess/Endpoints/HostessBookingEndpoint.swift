import Alamofire
import Foundation
import PromiseKit

protocol HostessBookingEndpointProtocol: AnyObject {
	func create(booking request: HostessBookingRequest) -> EndpointResponse<HostessResponse<HostessBookingResponse>>
    func bookings(for userID: Int, page: Int, size: Int) -> EndpointResponse<HostessResponse<HostessBookingsResponse>>
    func activeBookingsCount(for userID: Int) -> EndpointResponse<HostessResponse<Int>>
}

final class HostessBookingEndpoint: HostessEndpoint, HostessBookingEndpointProtocol {
    static let endpoint = "/reservation/"

	func create(booking request: HostessBookingRequest) -> EndpointResponse<HostessResponse<HostessBookingResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(endpoint: Self.endpoint + "booking", parameters: parameters)
    }

	func bookings(for userID: Int, page: Int, size: Int = 50) -> EndpointResponse<HostessResponse<HostessBookingsResponse>> {
		let params: [String: Any] = ["page": page, "client_id": userID, "size": size]
        return self.retrieve(endpoint: Self.endpoint + "bookings", parameters: params)
    }

    func activeBookingsCount(for userID: Int) -> EndpointResponse<HostessResponse<Int>> {
        let params: [String: Any] = ["client_id": userID]
        return self.retrieve(
            endpoint: Self.endpoint + "active",
            parameters: params
        )
    }
}
