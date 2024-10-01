import UIKit

final class HomeScreenAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = HomeScreenPresenter(
            restaurantsEndpoint: RestaurantsEndpoint(),
            hostessScheduleEndpoint: HostessScheduleEndpoint(),
            locationService: LocationService.shared,
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
			notificationEndpoint: PrimePassNotifyEndpoint(), 
			eventsEndpoint: EventsEndpoint(), 
			bannersEndpoint: BannersEndpoint(),
			favoritesService: FavoritesService(endpoint: FavoritesActionsEndpoint()),
            authService: AuthService(),
            notificationPersistenceService: NotificationPersistenceService(),
            restaurantsPersistenceService: RestaurantsPersistenceService.shared,
            assessmentPersistenceService: AssessmentPersistenceService.shared,
            locationBasedNotificationsService: LocationBasedNotificationsService.shared
        )
        let viewController = HomeScreenViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
