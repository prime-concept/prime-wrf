import UIKit

protocol RestaurantBookingModuleOutput: AnyObject {
    func updatePosition(withConfirmation: Bool, withDeposit: Bool, withComment: Bool)
    func updateBookingAvailability(isAvailable: Bool)
    func requestPhoneCall()

    func requestUserAuthorization()
}

final class RestaurantBookingAssembly: Assembly {
    private var moduleOutput: RestaurantBookingModuleOutput?
    private let primePassID: PrimePassRestaurantIDType
    private let hostessScheduleKey: String
    private var menu: String?
    private var restaurantId: String
    private var restaurantName: String

    init(
        restaurantPrimePassID: PrimePassRestaurantIDType,
        hostessScheduleKey: String,
        menu: String?,
        restaurantId: String,
        restaurantName: String,
        moduleOutput: RestaurantBookingModuleOutput? = nil
    ) {
        self.primePassID = restaurantPrimePassID
        self.hostessScheduleKey = hostessScheduleKey
        self.menu = menu
        self.moduleOutput = moduleOutput
        self.restaurantName = restaurantName
        self.restaurantId = restaurantId
    }

    func makeModule() -> UIViewController {
        let presenter = RestaurantBookingPresenter(
            restaurantID: self.primePassID,
            hostessScheduleKey: hostessScheduleKey,
            restaurantName: self.restaurantName,
            authService: AuthService(),
            scheduleEndpoint: HostessScheduleEndpoint(),
            bookingEndpoint: HostessBookingEndpoint(),
            hostessRestaurantEndpoint: HostessRestaurantEndpoint()
        )
        let viewController = RestaurantBookingViewController(
            presenter: presenter,
            menu: self.menu,
            restaurantId: self.restaurantId,
            moduleOutput: self.moduleOutput
        )
        presenter.viewController = viewController

        return viewController
    }
}
