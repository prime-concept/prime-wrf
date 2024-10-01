import Foundation
import PromiseKit

protocol ProfileBookingPresenterProtocol: AnyObject {
    func loadBookings()

    func select(id: HostessBooking.IDType)
    func reloadBookings(canceling id: HostessBooking.IDType)
    func requestBooking(id: HostessBooking.IDType)
    func didTapOnDeliveryTab()
}

final class ProfileBookingPresenter: ProfileBookingPresenterProtocol {
    weak var viewController: ProfileBookingViewControllerProtocol?

    private let hostessEndpoint: HostessBookingEndpointProtocol
    private let restaurantsEndpoint: RestaurantsEndpointProtocol
    private let authService: AuthServiceProtocol
    private var page: Int = 0
    private var isLoaded: Bool = false
    private var bookings: [HostessBooking] = []
    private var restaurants: Set<Restaurant> = []

    private var loadingDispatchGroup = DispatchGroup()
    // Deeplink handler
    private var requestBookingCompletion: (() -> Void)?

    private lazy var dateFormat: DateFormatter = {
        let dateFormat = FormatterHelper.makeCorrectLocaleDateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.dateFormat = "dd MMM, HH:mm"
        return dateFormat
    }()

    init(
        endpoint: HostessBookingEndpointProtocol,
        restaurantsEndpoint: RestaurantsEndpointProtocol,
        authService: AuthServiceProtocol
    ) {
        self.hostessEndpoint = endpoint
        self.restaurantsEndpoint = restaurantsEndpoint
        self.authService = authService

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.loadBookings),
            name: .newBooking,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    func loadBookings() {
        self.page = 0
        self.isLoaded = false
        self.bookings = []
        self.restaurants = []
        self.loadBookingsPerPage()
    }

    func loadBookingsPerPage() {
        guard let authData = self.authService.authorizationData else {
            return
        }

        self.loadingDispatchGroup.enter()
        self.loadingDispatchGroup.notify(queue: .main) { [weak self] in
            self?.requestBookingCompletion?()
        }
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.hostessEndpoint.bookings(for: authData.userID, page: self.page, size: 50).result
        }.then(on: queue) {
            // swiftlint:disable:next line_length
            (response: HostessResponse<HostessBookingsResponse>) -> Promise<([Restaurant], [HostessBooking])> in
            let bookings = response.data?.content ?? []
            self.isLoaded = response.data?.last ?? true
			let restaurantsIDs: Set<Int> = Set(bookings.map(\.restaurantID))
			let restaurantsPromises = restaurantsIDs.map {
				self.restaurantsEndpoint.retrieve(restaurantID: "\($0)").result
			}
            return when(fulfilled: restaurantsPromises).map { restaurantsResponses in
				let restaurants = restaurantsResponses.flatMap(\.items)
				return (restaurants, bookings)
			}
        }.done(on: queue) { restaurants, bookings in
			/* print("[BKG] GOT \(bookings.count) BOOKINGS:")
			bookings.forEach { (booking) in
				print("[BKG] \(booking.restaurantID) \(booking.date) \(booking.status)")
			} */

            self.bookings.append(contentsOf: bookings)
            self.restaurants.formUnion(restaurants)

            let models = self.makeViewModel(
                bookings: self.bookings,
                restaurants: Array(self.restaurants)
            )

            DispatchQueue.main.async { [weak self] in
                self?.viewController?.set(bookings: models)
            }
            if !self.isLoaded {
                self.page += 1
                self.loadBookingsPerPage()
			}
			/* else {
				print("\n\n[BKG] \(self.bookings.count) BOOKINGS TOTAL:")
				self.bookings.forEach { (booking) in
					print("[BKG] \(booking.restaurantID) \(booking.date) \(booking.status)")
				}
			} */
            self.loadingDispatchGroup.leave()
        }.catch { error in
            self.loadingDispatchGroup.leave()

            self.viewController?.set(bookings: [])
            print("bookings presenter: error while retrieving bookings = \(String(describing: error))")
        }
    }

    func select(id: HostessBooking.IDType) {
        if let booking = self.bookings.first(where: { $0.id == id }),
           let restaurant = self.restaurants.first(
            where: { $0.primePassID == String(describing: booking.restaurantID) }
        ) {
            AnalyticsReportingService.shared.didTapOnBookingFromHistory(id: "\(booking.id)")
            self.viewController?.show(booking: booking, restaurant: restaurant)
        }
    }

    func reloadBookings(canceling id: HostessBooking.IDType) {
		self.loadBookings()
    }

    func requestBooking(id: HostessBooking.IDType) {
        let requestHandler: () -> Void = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            guard let booking = strongSelf.bookings.first(where: { $0.id == id }),
                  let restaurant = strongSelf.restaurants
                    .first(where: { $0.primePassID == String(describing: booking.restaurantID) }) else {
                return
            }

            strongSelf.viewController?.show(booking: booking, restaurant: restaurant)
        }

        guard self.bookings.isEmpty else {
            requestHandler()
            return
        }

        self.requestBookingCompletion = { requestHandler() }
    }
    
    func didTapOnDeliveryTab() {
        AnalyticsReportingService.shared.didTapOnDeliveryFromHistory()
    }

    // MARK: - Private API

    private func makeViewModel(
        bookings: [HostessBooking],
        restaurants: [Restaurant]
    ) -> [SectionViewModel] {
        let sections: [(String, [HostessBooking.BookingStatus])] = [
            ("Новые заявки", [.new]),
            ("Подтвержденные бронирования", [.confirmed, .inHall]),
            ("Не подтвержденные заявки", [.waiting]),
            ("Отмененные бронирования", [.cancelled, .notCome, .external]),
            ("Прошедшие бронирования", [.closed])
        ]

		let viewModel = sections.compactMap { (section, statuses) -> SectionViewModel in
            let bookingModels = bookings
                .filter { statuses.contains($0.status) }
                .compactMap { booking -> BookingItemViewModel? in
                    guard let restaurant = restaurants.first (
                        where: { $0.primePassID == String(describing: booking.restaurantID) }
                    ) else {
                        return nil
                    }
                    return self.makeViewModel(
                        index: booking.id,
                        booking: booking,
                        restaurant: restaurant
                    )
                }
            return SectionViewModel(name: section, bookings: bookingModels)
        }.filter { !$0.bookings.isEmpty }

		return viewModel
    }

    private func makeViewModel(index: Int, booking: HostessBooking, restaurant: Restaurant) -> BookingItemViewModel {
        return BookingItemViewModel(
            id: index,
            guests: booking.guests,
            dateText: self.dateFormat.string(from: booking.date),
            date: booking.date,
            restaurant: restaurant
        )
    }
}
