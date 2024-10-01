import UIKit

final class RestaurantAssembly: Assembly {
    private let restaurant: Restaurant
    private let assessment: PrimePassAssessment?

    private(set) var trackedScrollView: UIScrollView?

    init(restaurant: Restaurant, assessment: PrimePassAssessment? = nil) {
        self.restaurant = restaurant
        self.assessment = assessment
    }

    func makeModule() -> UIViewController {
        let presenter = RestaurantPresenter(
            restaurant: self.restaurant,
            assessment: self.assessment,
            restaurantEndpoint: RestaurantEndpoint(),
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
            sharingService: SharingService(),
            locationService: LocationService.shared,
            favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
            restaurantPersistenceService: RestaurantsPersistenceService.shared,
            restaurantDetailPersistenceService: RestaurantDetailPersistenceService.shared,
            authService: AuthService()
        )
        let viewController = RestaurantViewController(
            restaurantID: self.restaurant.primePassID,
            hostessScheduleKey: self.restaurant.hostessScheduleKey,
            restaurant: self.restaurant,
            presenter: presenter
        )
        presenter.viewController = viewController

        self.trackedScrollView = viewController.restaurantView?.scrollView

        return viewController
    }
}
