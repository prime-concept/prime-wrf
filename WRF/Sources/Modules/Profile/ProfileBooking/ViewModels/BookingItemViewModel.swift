import Foundation

struct BookingItemViewModel {
    let id: HostessBooking.IDType
    let guests: Int
    let dateText: String
    let date: Date
    let restaurant: Restaurant
}
