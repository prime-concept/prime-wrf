import UIKit

final class MapAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = MapPresenter(
            restaurantsEndpoint: RestaurantsEndpoint(),
            tagsEndpoint: TagsEndpoint(),
            hostessScheduleEndpoint: HostessScheduleEndpoint(),
            locationService: LocationService.shared,
            feedbackEndpoint: PrimePassFeedbackEndpoint(),
            notificationEndpoint: PrimePassNotifyEndpoint(),
            authService: AuthService(),
            notificationPersistenceService: NotificationPersistenceService(),
            tagsPersistenceService: TagPersistenceService.shared,
            restaurantsPersistenceService: RestaurantsPersistenceService.shared,
            assessmentPersistenceService: AssessmentPersistenceService.shared,
            tagContainerPersistenceService: TagContainerPersistenceService.shared,
            locationBasedNotificationsService: LocationBasedNotificationsService.shared
        )
        let viewController = MapViewController(presenter: presenter)
        presenter.viewController = viewController

        return viewController
    }
}
