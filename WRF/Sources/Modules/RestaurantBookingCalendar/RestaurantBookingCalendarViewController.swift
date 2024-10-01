import JTAppleCalendar
import UIKit

protocol RestaurantBookingCalendarViewControllerProtocol: AnyObject { }

protocol RestaurantBookingCalendarDelegate: AnyObject {
    func calendarDidSelectDate(_ date: Date)
}

final class RestaurantBookingCalendarViewController: UIViewController {
    let presenter: RestaurantBookingCalendarPresenterProtocol
    lazy var calendarView = self.view as? RestaurantBookingCalendarView

    weak var delegate: RestaurantBookingCalendarDelegate?

    enum Appearance {
        static let calendarRowCount: Int = 6
    }

    private let months = [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"
    ]
    private let date: Date

    init(presenter: RestaurantBookingCalendarPresenterProtocol, date: Date) {
        self.presenter = presenter
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = RestaurantBookingCalendarView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.calendarView?.updateCalendarView(delegate: self, dataSource: self)
        self.calendarView?.scrollToDate(date: self.date)

        self.updateMonth(Date())
    }

    // MARK: - Private api

    private func updateMonth(_ date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: date)
        let month = self.months[(components.month ?? 0) - 1]
        let year = components.year ?? 1900
        self.calendarView?.updateMonth(
            month: month,
            year: year
        )
    }
}

extension RestaurantBookingCalendarViewController: RestaurantBookingCalendarViewControllerProtocol { }

extension RestaurantBookingCalendarViewController: RestaurantBookingCalendarViewDelegate {
    func calendarViewDidSelectDate(date: Date) {
        self.dismiss(animated: true) {
            self.delegate?.calendarDidSelectDate(date)
        }
    }
}

extension RestaurantBookingCalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(
        _ calendar: JTAppleCalendarView,
        willDisplay cell: JTAppleCell,
        forItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) {
        self.calendarView?.configureCell(cell: cell, cellState: cellState)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        cellForItemAt date: Date,
        cellState: CellState,
        indexPath: IndexPath
    ) -> JTAppleCell {
        let cell: CalendarCell = calendar.dequeueReusableCell(for: indexPath)
        self.calendarView?.configureCell(cell: cell, cellState: cellState)
        return cell
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) {
        self.calendarView?.configureCell(cell: cell, cellState: cellState)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        didDeselectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) {
        self.calendarView?.configureCell(cell: cell, cellState: cellState)
    }

    func calendar(
        _ calendar: JTAppleCalendarView,
        shouldSelectDate date: Date,
        cell: JTAppleCell?,
        cellState: CellState
    ) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return date >= startOfDay
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        if let date = visibleDates.monthDates.first?.date {
            self.updateMonth(date)
        }
    }
}

extension RestaurantBookingCalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        calendar.scrollingMode = .stopAtEachCalendarFrame

        let calendar = Calendar.current
        // swiftlint:disable force_unwrapping
        let startDate = calendar.date(byAdding: .day, value: -1, to: Date())!
        let endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
        // swiftlint:enable force_unwrapping
        return ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: Appearance.calendarRowCount,
            generateOutDates: .off,
            firstDayOfWeek: .monday,
            hasStrictBoundaries: true
        )
    }
}
