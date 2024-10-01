import JTAppleCalendar
import SnapKit
import UIKit

protocol RestaurantBookingCalendarViewDelegate: AnyObject {
    func calendarViewDidSelectDate(date: Date)
}

extension RestaurantBookingCalendarView {
    struct Appearance {
        let calendarBackgroundColor = UIColor.white
        let calendarLineSpacing: CGFloat = 2
        let calendarItemSpacing: CGFloat = 5
        let calendarHeight: CGFloat = 190

        let topOffset: CGFloat = 25

        let buttonSize = CGSize(width: 120, height: 40)
        let buttonFont = UIFont.wrfFont(ofSize: 14)
        let buttonEditorLineHeight: CGFloat = 14
        let buttonInsets = LayoutInsets(left: 0, bottom: 15, right: 0)

        let calendarViewInset = LayoutInsets(top: 10, left: 26, right: 26)
        let calendarWeekDaysInset = LayoutInsets(top: 15, left: 40, right: 40)
    }
}

final class RestaurantBookingCalendarView: UIView {
    let appearance: Appearance

    weak var delegate: RestaurantBookingCalendarViewDelegate?

    private(set) lazy var calendarView: JTAppleCalendarView = {
        let calendar = JTAppleCalendarView()
        calendar.bounces = false
        calendar.minimumLineSpacing = self.appearance.calendarLineSpacing
        calendar.minimumInteritemSpacing = self.appearance.calendarItemSpacing
        calendar.showsHorizontalScrollIndicator = false
        calendar.scrollDirection = .horizontal
        calendar.backgroundColor = self.appearance.calendarBackgroundColor
        calendar.register(cellClass: CalendarCell.self)
        return calendar
    }()

    private lazy var calendarMonthYearView: CalendarMonthYearView = {
        let view = CalendarMonthYearView()
        view.previousMonthButton.addTarget(self, action: #selector(self.goToPreviousMonth), for: .touchUpInside)
        view.nextMonthButton.addTarget(self, action: #selector(self.goToNextMonth), for: .touchUpInside)
        return view
    }()
    private lazy var calendarWeekdaysView = CalendarWeekdaysView()

    private lazy var applyDateButton: ShadowButton = {
        let appearance = ShadowButton.Appearance(
            mainFont: self.appearance.buttonFont,
            mainEditorLineHeight: self.appearance.buttonEditorLineHeight,
            insets: self.appearance.buttonInsets
        )
        let button = ShadowButton(appearance: appearance)
        button.title = "Применить"
        button.addTarget(self, action: #selector(self.applyDate), for: .touchUpInside)
        return button
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public api

    func updateCalendarView(
        delegate: JTAppleCalendarViewDelegate,
        dataSource: JTAppleCalendarViewDataSource
    ) {
        self.calendarView.calendarDelegate = delegate
        self.calendarView.calendarDataSource = dataSource
        self.calendarView.reloadData()
    }

    func updateMonth(month: String, year: Int) {
        self.calendarMonthYearView.title = "\(month) \(year)"
    }

    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        guard let currentCell = cell as? CalendarCell else {
            return
        }
        currentCell.update(with: cellState)
        let cellHidden = cellState.dateBelongsTo != .thisMonth
        currentCell.isHidden = cellHidden
    }

    // MARK: - Public API

    func scrollToDate(date: Date) {
        self.calendarView.scrollToDate(date) {
            self.calendarView.selectDates([date])
        }
    }

    // MARK: - Private api

    @objc
    private func goToPreviousMonth() {
        self.calendarView.scrollToSegment(.previous)
    }

    @objc
    private func goToNextMonth() {
        self.calendarView.scrollToSegment(.next)
    }

    @objc
    private func applyDate() {
        if let selectedDate = self.calendarView.selectedDates.first {
            self.delegate?.calendarViewDidSelectDate(date: selectedDate)
        }
    }
}

extension RestaurantBookingCalendarView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.calendarMonthYearView)
        self.addSubview(self.calendarWeekdaysView)
        self.addSubview(self.calendarView)
        self.addSubview(self.applyDateButton)
    }

    func makeConstraints() {
        self.calendarMonthYearView.translatesAutoresizingMaskIntoConstraints = false
        self.calendarMonthYearView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
                    .offset(self.appearance.topOffset)
            } else {
                make.top
                    .equalToSuperview()
                    .offset(self.appearance.topOffset)
            }
            make.centerX.equalToSuperview()
        }

        self.calendarWeekdaysView.translatesAutoresizingMaskIntoConstraints = false
        self.calendarWeekdaysView.snp.makeConstraints { make in
            make.top
                .equalTo(self.calendarMonthYearView.snp.bottom)
                .offset(self.appearance.calendarWeekDaysInset.top)
            make.leading.equalToSuperview().offset(self.appearance.calendarWeekDaysInset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.calendarWeekDaysInset.right)
        }

        self.calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.calendarView.snp.makeConstraints { make in
            make.top
                .equalTo(self.calendarWeekdaysView.snp.bottom)
                .offset(self.appearance.calendarViewInset.top)
            make.leading.equalToSuperview().offset(self.appearance.calendarViewInset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.calendarViewInset.right)
            make.height.equalTo(self.appearance.calendarHeight)
        }

        self.applyDateButton.translatesAutoresizingMaskIntoConstraints = false
        self.applyDateButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(self.appearance.buttonSize)
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .offset(-self.appearance.buttonInsets.bottom)
            } else {
                make.bottom
                    .equalToSuperview()
                    .offset(-self.appearance.buttonInsets.bottom)
            }
        }
    }
}
