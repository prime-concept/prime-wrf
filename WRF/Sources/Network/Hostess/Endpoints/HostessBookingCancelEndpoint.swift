import Alamofire
import Foundation
import PromiseKit

protocol HostessBookingCancelEndpointProtocol: AnyObject {
    func cancel(_ booking: HostessBooking) -> EndpointResponse<HostessResponse<HostessBookingCancelResponse>>
}

final class HostessBookingCancelEndpoint: HostessEndpoint, HostessBookingCancelEndpointProtocol {
    static let endpoint = "/booking/cancel"

	func cancel(_ booking: HostessBooking) -> EndpointResponse<HostessResponse<HostessBookingCancelResponse>> {
		let urlWithParameters = "?booking_id=\(booking.id)&type=\(booking.type.rawValue)"
        return self.update(
            endpoint: HostessBookingCancelEndpoint.endpoint + urlWithParameters,
            encoding: URLEncoding.default
        )
    }
}
