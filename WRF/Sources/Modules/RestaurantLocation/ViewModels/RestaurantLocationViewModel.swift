import Foundation

struct RestaurantLocationsViewModel {
    let address: String?
    let taxi: Taxi?
    let coordinate: (latitude: Double, longitude: Double)?
    let placeTitle: String

    struct Taxi {
        let price: String
        let url: String?
    }
}
