import Foundation


struct HostessBookingsResponse: Codable {
    let content: [HostessBooking]
	let first: Bool
    let last: Bool

	let size: Int
	let number: Int
	let totalPages: Int
}

struct HostessBooking: Codable {
    typealias IDType = Int

    var id: IDType
    let restaurantID: Int
    let date: Date
    let timeKey: Date
    let guests: Int
    let status: BookingStatus
	let type: BookingType
	let deposit: Int?
	let visitTime: Int?

    func copyWithUpdatingParameters(status: BookingStatus) -> HostessBooking {
        return HostessBooking(
            id: self.id,
            restaurantID: self.restaurantID,
            date: self.date,
            timeKey: self.timeKey,
            guests: self.guests,
			status: self.status,
			type: self.type,
			deposit: self.deposit,
			visitTime: self.visitTime
        )
    }

    enum BookingStatus: String, Codable {
        case new = "NEW"
        case cancelled = "CANCELED"
        case confirmed = "CONFIRMED"
        case external = "EXTERNAL"
        case closed = "CLOSED"
        case inHall = "IN_HALL"
        case notCome = "NOT_COME"
        case waiting = "WAIT_LIST"
    }

	enum BookingType: String, Codable {
		case order
		case booking
	}

    enum CodingKeys: String, CodingKey {
        case id
        case restaurantID = "place_id"
        case date
        case timeKey = "time_key"
        case guests = "guest"
        case status = "status"
		case type
		case deposit
		case visitTime = "visit_time"
    }
}
