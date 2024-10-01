import IQKeyboardManagerSwift
import SafariServices
import UIKit

protocol RestaurantBookingViewControllerProtocol: BlockingLoaderPresentable {
    func set(model: RestaurantBookingViewModel?)
    func set(state: RestaurantBookingView.State)
    func showResult(successful: Bool, errorText: String?)
    func handleUnauthorizedUser()
}

final class RestaurantBookingViewController: UIViewController {
    private static let initialCounter = 1
    static let defaultVisitTime = 60

    private weak var moduleOutput: RestaurantBookingModuleOutput?

    let presenter: RestaurantBookingPresenterProtocol
    lazy var restaurantView = self.view as? RestaurantBookingView

    private var viewModel: RestaurantBookingViewModel?
    private var isSomeScheduleDidAlreadyShow = false
    private var menu: String?
    private var restaurantId: String

    // State
    private var selectedGuestsCount = RestaurantBookingViewController.initialCounter
    private var selectedTimeIndex: Int?
    private var selectedTime = Date()
    private var todayTimeIndex = Int()
    private lazy var checkoutPresentationManager = FloatingControllerPresentationManager(
        context: .checkout(showDeposit: false),
        groupID: RestaurantViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true
    )

    private lazy var calendarPresentationManager: FloatingControllerPresentationManager = {
        let manager = FloatingControllerPresentationManager(
            context: .calendar,
            groupID: RestaurantViewController.floatingControllerGroupID,
            sourceViewController: self,
            shouldMinimizePreviousController: true,
            grabberAppearance: .light
        )
        manager.contentInsetAdjustmentBehavior = .never
        return manager
    }()

    private lazy var presentationManager = FloatingControllerPresentationManager(
        context: .menu,
        groupID: RestaurantViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: nil
    )

    init(
        presenter: RestaurantBookingPresenterProtocol,
        menu: String?,
        restaurantId: String,
        moduleOutput: RestaurantBookingModuleOutput?
    ) {
        self.presenter = presenter
        self.menu = menu
        self.moduleOutput = moduleOutput
        self.restaurantId = restaurantId
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = RestaurantBookingView(
            frame: UIScreen.main.bounds,
            counter: RestaurantBookingViewController.initialCounter
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.restaurantView?.isMenuButtonEnabled = !(self.menu ?? "").isEmpty
		
		self.restaurantView?.updateCalendarSelected(day: Date() + 2.days)
        self.restaurantView?.delegate = self

        self.presenter.didLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }

    // MARK: - Private API

    private func resetToInitialStateIfNeeded() {
		if self.restaurantView?.state == .idle(nil) {
			return
		}
		self.restaurantView?.state = .idle(nil)
		self.moduleOutput?.updatePosition(withConfirmation: false, withDeposit: false, withComment: false)
    }
}

extension RestaurantBookingViewController: RestaurantBookingViewDelegate {
    func restaurantBookingViewDidRequestPhone(_ view: RestaurantBookingView) {
        self.moduleOutput?.requestPhoneCall()
    }

    func restaurantBookingView(_ view: RestaurantBookingView, didSelectGuests guests: Int) {
        self.selectedGuestsCount = guests
        self.resetToInitialStateIfNeeded()
        self.presenter.load(guests: self.selectedGuestsCount, date: self.selectedTime)
    }

    func restaurantBookingView(
        _ view: RestaurantBookingView,
        didSelectDay day: RestaurantBookingView.SelectedShortDay
    ) {
        guard let viewModel = self.viewModel else {
            return
        }

        if day != .today {
            AnalyticsReportingService.shared.didSelectTomorrowForBooking()
        }
        
		self.selectedTime = day == .today ? viewModel.today.date : viewModel.tomorrow.date.down(to: .day)
        self.resetToInitialStateIfNeeded()
        self.presenter.load(guests: self.selectedGuestsCount, date: self.selectedTime)
    }

    func restaurantBookingView(
        _ view: RestaurantBookingView,
        didSelectTimeIndex timeIndex: Int,
        isToday: Bool
    ) {
        self.selectedTimeIndex = timeIndex
        self.presenter.checkBookingSlot(at: timeIndex + (isToday ? self.todayTimeIndex : 0))
    }

    func restaurantBookingViewDidSelectCheckout(_ view: RestaurantBookingView) {
        // In current version use always confirmation w/o deposit
        self.restaurantView?.state = .confirmation
        // self.restaurantView?.state = .deposit
        self.presenter.didTapOnBookingButton()
        self.moduleOutput?.updatePosition(withConfirmation: true, withDeposit: false, withComment: true)
    }

    func restaurantBookingViewDidSelectMenu(_ view: RestaurantBookingView) {
        guard let menu = self.menu,
              let menuURL = URL(string: menu) else {
            return
        }
        
        self.presenter.didTapOnMenuButton(restaurantId: self.restaurantId)
        
        let controller = SFSafariViewController(url: menuURL)
        self.presentationManager.contentViewController = controller
        self.presentationManager.present()
    }

    func restaurantBookingViewDidSelectCalendar(_ view: RestaurantBookingView) {
        
        AnalyticsReportingService.shared.didSelectCalendarForBooking()
        
        let calendarController = RestaurantBookingCalendarAssembly(selectedDate: self.selectedTime).makeModule()
        self.calendarPresentationManager.contentViewController = calendarController
        self.calendarPresentationManager.present()

        // TODO: extract scrollView getter through assembly
        if let calendarViewController = calendarController as? RestaurantBookingCalendarViewController,
            let trackedScrollView = calendarViewController.calendarView?.calendarView {
            calendarViewController.delegate = self
            self.calendarPresentationManager.track(scrollView: trackedScrollView)
        }
    }

    func restaurantBookingViewDidConfirm(
        _ view: RestaurantBookingView,
        withComment comment: String,
        isToday: Bool
    ) {
        guard let timeIndex = self.selectedTimeIndex else {
            return
        }
        if isToday {
            self.presenter.submitBooking(timeIndex: (timeIndex + todayTimeIndex), comment: comment)
        } else {
            self.presenter.submitBooking(timeIndex: timeIndex, comment: comment)
        }
    }

    func restaurantBookingViewDidOpenToS(_ view: RestaurantBookingView) {
        let controller = SFSafariViewController(url: PGCMain.shared.config.cancelationRulesURL)
        self.presentationManager.contentViewController = controller
        self.presentationManager.present()
    }

    func currentSchedule(schedule: [String]) -> [String] {
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        guard let date = dateFormatter.date(from: "\(hour):\(minute)") else {
            return schedule
        }
        if let currentTimeIndex = schedule.firstIndex(where: { dateFormatter.date(from: $0) ?? date > date }) {
            self.todayTimeIndex = currentTimeIndex
            return Array(schedule[currentTimeIndex...])
        } else {
            return schedule
        }
    }
}

extension RestaurantBookingViewController: RestaurantBookingCalendarDelegate {
    func calendarDidSelectDate(_ date: Date) {
        self.selectedTime = date
        self.presenter.load(guests: self.selectedGuestsCount, date: self.selectedTime)
        self.restaurantView?.resetDaysButtons()

		let dat = Date() + 2.days
		let day = [self.selectedTime, dat].sorted(by: >)[0]
		self.restaurantView?.updateCalendarSelected(day: day)

        self.resetToInitialStateIfNeeded()
    }
}

extension RestaurantBookingViewController: RestaurantBookingViewControllerProtocol {
    func set(model: RestaurantBookingViewModel?) {
        guard let model = model else {
            self.moduleOutput?.updateBookingAvailability(isAvailable: false)
            return
        }
        self.restaurantView?.configure(with: model)

        if case .result(let schedule) = model.schedule {
            if schedule.isEmpty {
                // Request unavailable only on first try
                // See WRF-252 for details
                if !self.isSomeScheduleDidAlreadyShow, self.selectedGuestsCount == type(of: self).initialCounter {
                    self.moduleOutput?.updateBookingAvailability(isAvailable: false)
                    return
                }
            } else {
                self.isSomeScheduleDidAlreadyShow = true
                self.moduleOutput?.updateBookingAvailability(isAvailable: true)
            }
        }

        self.viewModel = model
        self.selectedTimeIndex = nil
    }

    func set(state: RestaurantBookingView.State) {
        self.restaurantView?.state = state
    }

    func showResult(successful: Bool, errorText: String?) {
        self.restaurantView?.state = .result(successful, errorText)

        if successful {
            self.resetToInitialStateIfNeeded()
        }
    }

    func handleUnauthorizedUser() {
        self.moduleOutput?.requestUserAuthorization()
    }
}
