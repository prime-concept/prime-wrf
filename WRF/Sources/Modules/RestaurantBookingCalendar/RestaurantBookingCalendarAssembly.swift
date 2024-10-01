import UIKit

final class RestaurantBookingCalendarAssembly: Assembly {
    private let selectedDate: Date

    init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
    }

    func makeModule() -> UIViewController {
        let presenter = RestaurantBookingCalendarPresenter()
        let viewController = RestaurantBookingCalendarViewController(
            presenter: presenter,
            date: self.selectedDate
        )
        presenter.viewController = viewController

        return viewController
    }
}
