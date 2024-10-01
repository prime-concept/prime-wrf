import Foundation
import PromiseKit

extension Notification.Name {
    static let newBooking = Notification.Name("newBooking")
}

protocol RestaurantBookingPresenterProtocol: AnyObject {
    func didLoad()
    func load(guests: Int, date: Date)
    func checkBookingSlot(at timeIndex: Int)
    func submitBooking(timeIndex: Int, comment: String)
    func didTapOnBookingButton()
    func didTapOnMenuButton(restaurantId: String)
}

final class RestaurantBookingPresenter: RestaurantBookingPresenterProtocol {
    private static let initialCounter = 1

    weak var viewController: RestaurantBookingViewControllerProtocol?
    
    private let scheduleEndpoint: HostessScheduleEndpointProtocol
    private let bookingEndpoint: HostessBookingEndpointProtocol
    private let hostessRestaurantEndpoint: HostessRestaurantEndpointProtocol
    private let restaurantID: PrimePassRestaurantIDType
    private let hostessScheduleKey: String
    private let authService: AuthServiceProtocol

    private var schedule: HostessSchedule?
    private var selectedDate: Date?
    private var indexOffset = 0
    private var guestsCount = 1
    private var bookingBanquetLimits: Int?
    private var onlineBookingCloseTime: String?
    private var restaurantName: String

    init(
        restaurantID: PrimePassRestaurantIDType,
        hostessScheduleKey: String,
        restaurantName: String,
        authService: AuthServiceProtocol,
        scheduleEndpoint: HostessScheduleEndpointProtocol,
        bookingEndpoint: HostessBookingEndpointProtocol,
        hostessRestaurantEndpoint: HostessRestaurantEndpointProtocol
    ) {
        self.restaurantID = restaurantID
        self.hostessScheduleKey = hostessScheduleKey
        self.restaurantName = restaurantName
        self.authService = authService
        self.scheduleEndpoint = scheduleEndpoint
        self.bookingEndpoint = bookingEndpoint
        self.hostessRestaurantEndpoint = hostessRestaurantEndpoint
    }

    func didLoad() {
        guard let id = Int(self.restaurantID) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.hostessRestaurantEndpoint.retrieve(id: id).result
        }.done { result in
            guard let data = result.data else {
                print("booking presenter: error while retrieving restaurant = \(String(describing: result.error))")
                return
            }
            self.bookingBanquetLimits = data.maxOnlineGuests
            self.onlineBookingCloseTime = data.onlineCloseAfter
            self.load(guests: Self.initialCounter, date: Date())
        }.catch { error in
            print("booking presenter: error while retrieving restaurant = \(String(describing: error))")
        }
    }

    func checkBookingSlot(at timeIndex: Int) {
        guard let onlineBookingCloseTimeString = self.onlineBookingCloseTime,
              let bookingTimeString = self.schedule?.timeData[safe: timeIndex + self.indexOffset],
			  let bookingCloseTime = onlineBookingCloseTimeString.date("HH:mm:ss"),
			  let bookingTime = bookingTimeString.date("YYYY-MM-dd'T'HH:mm:ss")
        else {
            self.viewController?.set(
                state: .idle("На данное бронирование действует ограничение по времени. Подробная информация будет направлена в подтверждении бронирования.")
            )
            return
        }

		let today = bookingTime.down(to: .day)
		let bookingClose = today + bookingCloseTime.hours + bookingCloseTime.minutes + bookingCloseTime.seconds

		if bookingClose > bookingTime {
			self.viewController?.set(state: .idle(nil))
			return
		}

		self.viewController?.set(
			state: .phone(
				.timeLimit("На данное время действует депозитная система.\nВы можете забронировать стол по звонку в ресторан.")
			)
		)
    }

    func load(guests: Int, date: Date) {
        if self.restaurantID.isEmpty {
            self.viewController?.set(model: nil)
            print("restaurant booking: empty prime pass place id, return")
            return
        }

        print("restaurant booking: load data for guests = \(guests), date = \(date)")
        self.guestsCount = guests
        self.selectedDate = date

        let calendar = FormatterHelper.makeCorrectLocaleCalendar()

        func day(_ date: Date) -> Int {
            return calendar.component(.day, from: date)
        }

        func dayOfWeek(_ date: Date) -> String {
            let daysOfWeek = calendar.shortStandaloneWeekdaySymbols
            return daysOfWeek[calendar.component(.weekday, from: date) - 1]
        }

        func compareTwoDays(lhs: Date, rhs: Date) -> Bool {
            return calendar.component(.year, from: lhs) == calendar.component(.year, from: rhs) &&
                calendar.component(.month, from: lhs) == calendar.component(.month, from: rhs) &&
                calendar.component(.day, from: lhs) == calendar.component(.day, from: rhs)
        }

        guard let today = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()),
              let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
            return
        }

        let todayDescription = RestaurantBookingViewModel.DayDescription(
            shortDayOfWeek: dayOfWeek(today),
            date: today,
            dayNumber: "\(day(today))",
            dayDescription: "сегодня",
            isSelected: compareTwoDays(lhs: date, rhs: today)
        )

        let tomorrowDescription = RestaurantBookingViewModel.DayDescription(
            shortDayOfWeek: dayOfWeek(tomorrow),
            date: tomorrow,
            dayNumber: "\(day(tomorrow))",
            dayDescription: "завтра",
            isSelected: compareTwoDays(lhs: date, rhs: tomorrow)
        )

        if let banquetLimit = self.bookingBanquetLimits,
           guests >= banquetLimit
        {
            self.viewController?.set(state: .phone(.guestsCount))
            return
        }

        let viewModel = RestaurantBookingViewModel(
            schedule: .loading,
            today: todayDescription,
            tomorrow: tomorrowDescription
        )
        self.viewController?.set(model: viewModel)

        DispatchQueue.global(qos: .userInitiated).promise {
            self.scheduleEndpoint.schedule(
                for: self.hostessScheduleKey,
                restaurantID: self.restaurantID,
                guests: 2,
                date: date
            ).result
        }.done { result in
            guard let data = result.data else {
                print("booking presenter: error while retrieving schedule = \(String(describing: result.error))")

                let model = RestaurantBookingViewModel(
                    schedule: .result([]),
                    today: todayDescription,
                    tomorrow: tomorrowDescription
                )
                self.viewController?.set(model: model)
                return
            }

            let timeData = data.eligibleTimeData(for: date)

            let viewModel = RestaurantBookingViewModel(
                schedule: .result(timeData),
                today: todayDescription,
                tomorrow: tomorrowDescription
            )
            self.viewController?.set(model: viewModel)
            self.schedule = data
			self.indexOffset = max(0, data.timeData.count - timeData.count)
        }.catch { _ in
            let model = RestaurantBookingViewModel(
                schedule: .result([]),
                today: todayDescription,
                tomorrow: tomorrowDescription
            )
            self.viewController?.set(model: model)
        }
    }

	private lazy var timeDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		
		return dateFormatter
	}()

    func submitBooking(timeIndex: Int, comment: String) {
        guard let authData = self.authService.authorizationData else {
            self.viewController?.handleUnauthorizedUser()
            return
        }

		let index = timeIndex + self.indexOffset
        guard let selectedTimeString = self.schedule?.timeData[safe: index] else {
            return
        }

        let debounceDelay: TimeInterval = 0.5

		/*
		 1 гость - 90 минут
		 2-4 клиента - 120 минут
		 5 клиентов - 150 минут
		 6-7 клиентов - 180 минут
		 */
        let visitTime = { () -> Int in
			switch self.guestsCount {
				case 1:
					return 90
				case 2...4:
					return 120
				case 5:
					return 150
				case 6...:
					return 180
				default:
					return 0
			}
        }()

        self.viewController?.showLoading()
        DispatchQueue.global(qos: .userInitiated).promise { () -> Promise<HostessResponse<HostessBookingResponse>> in
            let request = HostessBookingRequest(
                userID: authData.userID,
                restaurantID: self.restaurantID,
                date: selectedTimeString,
                visitTime: visitTime,
                guest: self.guestsCount,
                deposit: 0,
                status: .external,
                comment: comment
            )
            return self.bookingEndpoint.create(booking: request).result
        }.done { [weak self] response in
            
            if let id = self?.restaurantID {
                AnalyticsReportingService.shared.didBookRestaurantSuccessfully(restaurantId: id,
                                                                     name: self?.restaurantName ?? "")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay) {
                self?.viewController?.hideLoading()
                let successful = response.isSuccessful
                var errorText: String?
                if successful == false, response.errorMessage == "Not found: suitable table" {
                    errorText = """
                    На данное время и количество персон столы
                    в ресторане забронированы. Свяжитесь с нами по телефону, и мы подберем для вас
                    оптимальное время посещения.
                    """
                }
                self?.viewController?.showResult(
                    successful: response.isSuccessful,
                    errorText: errorText
                )

                NotificationCenter.default.post(name: .newBooking, object: nil)
            }
        }.catch { _ in
            self.viewController?.hideLoading()
        }
    }
    
    func didTapOnBookingButton() {
        AnalyticsReportingService.shared.didTapOnBookingButton(restaurantId: self.restaurantID,
                                                               name: self.restaurantName)
    }
    
    func didTapOnMenuButton(restaurantId: String) {
        AnalyticsReportingService.shared.didTapOnMenuButton(restaurantId: restaurantId)
    }

    private func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
