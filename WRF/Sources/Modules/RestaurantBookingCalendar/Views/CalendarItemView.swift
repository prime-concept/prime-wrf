import JTAppleCalendar
import UIKit

extension CalendarItemView {
    struct Appearance {
        let calendarPastColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let calendarAfterColor = UIColor.black

        let weekDayFont = UIFont.wrfFont(ofSize: 16, weight: .light)
        let weekendFont = UIFont.wrfFont(ofSize: 16, weight: .medium)

        let separatorSize = CGSize(width: 20, height: 1)
        let separatorColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)

        let separatorOffset: CGFloat = 4
    }
}

final class CalendarItemView: UIView {
    let appearance: Appearance

    private lazy var calendar = Calendar.current

    private lazy var shadowBackgroundView = ShadowBackgroundView()

    private(set) lazy var itemLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    func update(with cellState: CellState) {
        self.itemLabel.text = cellState.text

        self.separatorView.isHidden = !self.calendar.isDateInToday(cellState.date)
        self.shadowBackgroundView.isHidden = !cellState.isSelected

        if cellState.day == .saturday || cellState.day == .sunday {
            self.itemLabel.font = self.appearance.weekendFont
        } else {
            self.itemLabel.font = self.appearance.weekDayFont
        }

        let startOfDay = self.calendar.startOfDay(for: Date())
        if cellState.date >= startOfDay {
            self.itemLabel.textColor = self.appearance.calendarAfterColor
        } else {
            self.itemLabel.textColor = self.appearance.calendarPastColor
        }
    }
}

extension CalendarItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.shadowBackgroundView)
        self.addSubview(self.itemLabel)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.shadowBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.itemLabel.translatesAutoresizingMaskIntoConstraints = false
        self.itemLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(self.appearance.separatorSize)
            make.bottom.equalToSuperview().offset(-self.appearance.separatorOffset)
        }
    }
}
