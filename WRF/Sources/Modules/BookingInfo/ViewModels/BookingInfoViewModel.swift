import Foundation

struct BookingInfoViewModel {
    let primePassID: PrimePassRestaurantIDType
    let title: String
    let address: String?
    let distanceText: String?
    let imageURL: URL?
    let rating: Int
    let ratingFloat: Float?
    let assessmentsCountText: String?
    let assessmentsCount: Int?
    let price: String?
    let coordinate: (latitude: Double, longitude: Double)?
    let booking: Booking
    let reviewRating: ReviewRating?
    let isCancellable: Bool
	let isMobileOriginated: Bool
    let cancelTitle: String

    struct Booking {
        let guests: String
        let date: String
        let time: String
    }

    struct ReviewRating {
        let reviewsRating: Float
        let reviewsTotal: Int
    }
}
