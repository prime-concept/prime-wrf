import UIKit

final class ProfileBookingInfoAssembly: Assembly {
    private let booking: HostessBooking
    private let restaurant: Restaurant

    init(booking: HostessBooking, restaurant: Restaurant) {
        self.booking = booking
        self.restaurant = restaurant
    }

    func makeModule() -> UIViewController {
        let presenter = ProfileBookingInfoPresenter(
            booking: self.booking,
            restaurant: self.restaurant,
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
            bookingEndpoint: HostessBookingEndpoint(),
            bookingCancelEndpoint: HostessBookingCancelEndpoint(),
            locationService: LocationService.shared,
            authService: AuthService()
        )
        let viewController = ProfileBookingInfoViewController(
            restaurant: self.restaurant,
            presenter: presenter
        )
        presenter.viewController = viewController

        return viewController
    }
}
