import UIKit

protocol RestaurantBookingCalendarPresenterProtocol { }

final class RestaurantBookingCalendarPresenter: RestaurantBookingCalendarPresenterProtocol {
    weak var viewController: RestaurantBookingCalendarViewControllerProtocol?
}