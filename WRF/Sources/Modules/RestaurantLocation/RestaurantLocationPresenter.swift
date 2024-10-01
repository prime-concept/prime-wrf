import CoreLocation
import PromiseKit
import UIKit

extension Notification.Name {
    static let restaurantLocationUpdate = Notification.Name("restaurantLocationUpdate")
}

protocol RestaurantLocationPresenterProtocol {
    func loadLocations()
    func didTapOpenRoute()
}

final class RestaurantLocationPresenter: RestaurantLocationPresenterProtocol {
    weak var viewController: RestaurantLocationViewControllerProtocol?
    
    private var restaurant: Restaurant
    private let endpoint: TaxiEndpointProtocol
    private let locationService: LocationServiceProtocol
    
    init(
        restaurant: Restaurant,
        endpoint: TaxiEndpointProtocol,
        locationService: LocationServiceProtocol
    ) {
        self.restaurant = restaurant
        self.endpoint = endpoint
        self.locationService = locationService
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refresh),
            name: .restaurantLocationUpdate,
            object: nil
        )
    }
    
    func loadLocations() {
        self.viewController?.set(model: self.makeViewModel(restaurant: self.restaurant, taxiResponse: nil))
        
        let lastLocation = self.locationService.lastLocation?.coordinate
        self.loadTaxi(location: lastLocation)
        
        guard lastLocation == nil else {
            return
        }
        
        self.locationService.fetchLocation(
            completion: { result in
                guard case .success(let location) = result else {
                    return
                }
                self.loadTaxi(location: location)
            }
        )
    }
    
    func didTapOpenRoute() {
        AnalyticsReportingService.shared.didTapOpenRoute(restaurantId: self.restaurant.id)
    }
    
    // MARK: - Private API
    
    private func loadTaxi(location: CLLocationCoordinate2D?) {
        return
        
        /** Taxi loading temporarily disabled
         guard let location = location else {
         return
         }
         DispatchQueue.global(qos: .userInitiated).promise {
         self.endpoint.calculate(
         start: Coordinate(
         latitude: location.latitude,
         longitude: location.longitude
         ),
         end: self.restaurant.coordinates
         ).result
         }.done {
         let viewModel = self.makeViewModel(restaurant: self.restaurant, taxiResponse: $0)
         self.viewController?.set(model: viewModel)
         }.cauterize()
         */
    }
    
    private func makeViewModel(restaurant: Restaurant, taxiResponse: TaxiResponse?) -> RestaurantLocationsViewModel {
        let taxi: RestaurantLocationsViewModel.Taxi? = {
            if let partner = taxiResponse?.partners.first(where: { $0.partner == "yandex" }) {
                return RestaurantLocationsViewModel.Taxi(
                    price: "\(partner.price) руб.",
                    url: partner.url
                )
            }
            return nil
        }()
        
        var coordinate: (latitude: Double, longitude: Double)? = nil
        if let coordinates = restaurant.coordinates {
            coordinate = (coordinates.latitude, coordinates.longitude)
        }

        return RestaurantLocationsViewModel(
            address: restaurant.address,
            taxi: taxi,
            coordinate: coordinate,
            placeTitle: restaurant.title
        )
    }
    
    @objc
    private func refresh(_ notification: Notification) {
        guard let restaurant = notification.userInfo?["restaurant"] as? Restaurant else {
            return
        }
        
        self.restaurant = restaurant
        self.loadLocations()
    }
}
