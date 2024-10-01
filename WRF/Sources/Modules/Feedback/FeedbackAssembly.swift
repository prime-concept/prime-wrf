import UIKit

final class FeedbackAssembly: Assembly {
    private let restaurantID: PrimePassRestaurantIDType
    private let placeName: String

    init(placeName: String, restaurantID: PrimePassRestaurantIDType) {
        self.restaurantID = restaurantID
        self.placeName = placeName
    }

    func makeModule() -> UIViewController {
        let presenter = FeedbackPresenter(
            restaurantID: self.restaurantID,
            primePassFeedbackEndpoint: PrimePassFeedbackEndpoint(),
            authService: AuthService()
        )
        let viewController = FeedbackViewController(presenter: presenter, placeName: self.placeName)
        presenter.viewController = viewController

        return viewController
    }
}
