import SnapKit
import UIKit

protocol RestaurantBookingViewDelegate: AnyObject {
    func restaurantBookingViewDidSelectCheckout(_ view: RestaurantBookingView)
    func restaurantBookingViewDidSelectMenu(_ view: RestaurantBookingView)
    func restaurantBookingViewDidSelectCalendar(_ view: RestaurantBookingView)
    func restaurantBookingViewDidConfirm(_ view: RestaurantBookingView, withComment comment: String, isToday: Bool)
    func restaurantBookingViewDidRequestPhone(_ view: RestaurantBookingView)
    func restaurantBookingView(_ view: RestaurantBookingView, didSelectDay day: RestaurantBookingView.SelectedShortDay)
    func restaurantBookingView(_ view: RestaurantBookingView, didSelectGuests guests: Int)
    func restaurantBookingView(_ view: RestaurantBookingView, didSelectTimeIndex timeIndex: Int, isToday: Bool)
    func restaurantBookingViewDidOpenToS(_ view: RestaurantBookingView)
    func currentSchedule(schedule: [String]) -> [String]
}

extension RestaurantBookingView {
    struct Appearance {
        let guestsStepperInsets = LayoutInsets(top: 5, left: 15, right: 15)
        let dayButtonSize = CGSize(width: 50, height: 51)
        let dayButtonsInsets = LayoutInsets(top: 5, right: 15)
        let dayButtonsSpacing: CGFloat = 5
        var calendarButtonTintColor = UIColor.black

        let actionViewHeight: CGFloat = 41
        let actionViewInsets = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)

        let timePickerInsets = LayoutInsets(top: 15, left: 15, right: 0)
        let timePickerHeight: CGFloat = 39

        let phoneBookingAvailableFont = UIFont.wrfFont(ofSize: 15)
        let phoneBookingAvailableEditorLineHeight: CGFloat = 22

        let confirmationButtonFont = UIFont.wrfFont(ofSize: 14)
        let confirmationButtonEditorLineHeight: CGFloat = 16
        let confirmationButtonHeight: CGFloat = 40

        let phoneButtonFont = UIFont.wrfFont(ofSize: 14)
        let phoneIconSize = CGSize(width: 40, height: 40)

        let phoneBookingStepperTopOffset: CGFloat = 65
        let phoneBookingDescriptionInsets = LayoutInsets(top: 15, left: 15, right: 15)

        let commentPlaceholderFont = UIFont.wrfFont(ofSize: 13, weight: .light)
        let commentTextInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let commentBorderColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        let commentInsets = UIEdgeInsets(top: 7, left: 0, bottom: 0, right: 15)
    }
}

final class RestaurantBookingView: UIView {
    private static let successHideInterval: TimeInterval = 5.0

    let appearance: Appearance
    weak var delegate: RestaurantBookingViewDelegate?

    private lazy var calendarButton: CalendarInteractiveButton = {
        let button = CalendarInteractiveButton(type: .system)
        button.tintColor = self.appearance.calendarButtonTintColor
        button.addTarget(self, action: #selector(self.calendarButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var todayDayButton: RestaurantBookingDayButton = {
        let button = RestaurantBookingDayButton()
        button.isSelected = true
        button.addTarget(self, action: #selector(self.switchDay(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var timePickerView = RestaurantBookingTimePickerView()

    private lazy var ofertaCheckboxView: RestaurantBookingCheckoutAgreementView = {
        let view = RestaurantBookingCheckoutAgreementView()
        view.onChange = { [weak self] value in
            self?.confirmationButton.isEnabled = value
        }
        view.onLinkClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.restaurantBookingViewDidOpenToS(strongSelf)
        }
        view.isHidden = true
        return view
    }()

    private lazy var commentView: GrowingTextView = {
        var appearance: GrowingTextView.Appearance = ApplicationAppearance.appearance()
        appearance.textInsets = self.appearance.commentTextInsets
        appearance.minHeight = 83
        let view = GrowingTextView(appearance: appearance)
        view.font = self.appearance.commentPlaceholderFont
        view.placeholder = "Комментарий"
        view.maxTextLength = 200
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = self.appearance.commentBorderColor.cgColor
        view.delegate = self
        return view
    }()

    private lazy var commentViewContainer: UIView = {
        let view = UIView()
        view.addSubview(self.commentView)
        self.commentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.commentInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.commentInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.commentInsets.left)
			make.trailing.equalToSuperview().inset(self.appearance.commentInsets.right)
        }
        view.isHidden = true
        return view
    }()

    private lazy var depositView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            // Mock
            make.height.equalTo(79)
        }
        view.isHidden = true
        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.timePickerView,
                self.infoView,
                self.depositView,
                self.commentViewContainer,
				self.ofertaCheckboxView,
				self.confirmationButton,
				self.actionView,
				self.phoneDescriptionLabel,
				self.phoneBookingButton,
            ]
        )
		stackView.spacing = 15
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var tomorrowDayButton: RestaurantBookingDayButton = {
        let button = RestaurantBookingDayButton()
        button.addTarget(self, action: #selector(self.switchDay(_:)), for: .touchUpInside)
        return button
    }()

    private let guestsStepper: RestaurantBookingStepper

    private lazy var bookingContentView = UIView()

    private lazy var dayButtonsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [self.todayDayButton, self.tomorrowDayButton, self.calendarButton]
        )
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.dayButtonsSpacing
        return stackView
    }()

    private lazy var infoView: RestaurantBookingInfoView = {
        let view = RestaurantBookingInfoView()
        view.isHidden = true
        return view
    }()

    private lazy var actionView: RestaurantBookingActionView = {
        let view = RestaurantBookingActionView()
        view.onBookingButtonClicked = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if case .phone(let limit) = strongSelf.state,
               case .timeLimit = limit {
                strongSelf.delegate?.restaurantBookingViewDidRequestPhone(strongSelf)
            } else {
                strongSelf.actionView.isHidden = true
                strongSelf.delegate?.restaurantBookingViewDidSelectCheckout(strongSelf)
            }
        }
        view.onMenuButtonClicked = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.restaurantBookingViewDidSelectMenu(strongSelf)
        }
        return view
    }()

    private lazy var confirmationButton: UIControl = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.confirmationButtonFont
        appearance.mainEditorLineHeight = self.appearance.confirmationButtonEditorLineHeight
        let button = ShadowButton(appearance: appearance)
        button.title = "Отправить заявку"
        button.isHidden = true
        button.addTarget(self, action: #selector(self.confirmationClicked), for: .touchUpInside)
        return button
    }()

    private lazy var phoneBookingButton: ShadowIconButton = {
        var appearance: ShadowIconButton.Appearance = ApplicationAppearance.appearance()
        appearance.iconSize = self.appearance.phoneIconSize
        appearance.spacing = 0
        let button = ShadowIconButton(appearance: appearance)
        button.title = "Забронировать"
        button.iconImage = #imageLiteral(resourceName: "restaurant-phone")
        button.addTarget(self, action: #selector(self.phoneBookingClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var phoneDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.phoneBookingAvailableFont
        label.textColor = self.appearance.calendarButtonTintColor
        label.numberOfLines = 0
        label.isHidden = true
        label.attributedText = LineHeightStringMaker.makeString(
            "На данное количество гостей действует депозитная система. Вы можете забронировать стол по звонку в ресторан.",
            editorLineHeight: self.appearance.phoneBookingAvailableEditorLineHeight,
            font: self.appearance.phoneBookingAvailableFont
        )
        return label
    }()

    private lazy var resultView: RestaurantBookingResultView = {
        let view = RestaurantBookingResultView()
        view.onRetry = { [weak self] in
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self?.resultView.alpha = 0.0
                },
                completion: { _ in
                    self?.resultView.isHidden = true
                    self?.bookingContentView.isHidden = false
                }
            )
        }
        view.onDone = { [weak self] in
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self?.resultView.alpha = 0.0
                },
                completion: { _ in
                    self?.bookingContentView.isHidden = false
                    self?.resultView.isHidden = true
                }
            )
        }
        view.isHidden = true
        return view
    }()

    var state: State = .idle(nil) {
        didSet {
            switch self.state {
            case .idle(let text):
                self.timePickerView.isHidden = false
                self.phoneDescriptionLabel.isHidden = true
                self.phoneBookingButton.isHidden = true
                self.ofertaCheckboxView.isHidden = true
                self.confirmationButton.isHidden = true
                self.commentViewContainer.isHidden = true
                self.depositView.isHidden = true
                self.infoView.isHidden = text == nil
                self.infoView.setText(text)
                self.actionView.isHidden = false
                self.actionView.isBookingWithPhoneEnabled = false
            case .phone(let reason):
                self.ofertaCheckboxView.isHidden = true
                self.confirmationButton.isHidden = true
                self.depositView.isHidden = true
                self.commentViewContainer.isHidden = true
                switch reason {
                case .timeLimit(let text):
                    self.timePickerView.isHidden = false
                    self.phoneDescriptionLabel.isHidden = true
                    self.phoneBookingButton.isHidden = true
                    self.infoView.isHidden = false
                    self.infoView.setText(text)
                    self.actionView.isHidden = false
                    self.actionView.isBookingWithPhoneEnabled = true
                case .guestsCount:
                    self.timePickerView.isHidden = true
                    self.phoneDescriptionLabel.isHidden = false
                    self.phoneBookingButton.isHidden = false
                    self.actionView.isHidden = true
                    self.actionView.isBookingWithPhoneEnabled = false
                    self.infoView.isHidden = true
                }
            case .confirmation:
                self.timePickerView.isHidden = false
                self.phoneDescriptionLabel.isHidden = true
                self.phoneBookingButton.isHidden = true
                self.ofertaCheckboxView.isHidden = false
                self.confirmationButton.isHidden = false
                self.commentViewContainer.isHidden = false
                self.depositView.isHidden = true
                self.infoView.isHidden = true
                self.actionView.isHidden = true
                self.actionView.isBookingWithPhoneEnabled = false
            case .deposit:
                self.timePickerView.isHidden = false
                self.phoneDescriptionLabel.isHidden = true
                self.phoneBookingButton.isHidden = true
                self.ofertaCheckboxView.isHidden = false
                self.confirmationButton.isHidden = false
                self.commentViewContainer.isHidden = true
                self.depositView.isHidden = false
                self.infoView.isHidden = true
                self.actionView.isHidden = true
                self.actionView.isBookingWithPhoneEnabled = false
            case let .result(isSuccessful, errorText):
                isSuccessful ? self.showSuccess() : self.showError(with: errorText)
            }

			self.invalidateIntrinsicContentSize()
        }
    }

    var isMenuButtonEnabled = false {
        didSet {
            self.actionView.isMenuButtonEnabled = self.isMenuButtonEnabled
        }
    }

    init(frame: CGRect = .zero, counter: Int, appearance: Appearance = ApplicationAppearance.appearance()) {
        self.appearance = appearance
        self.guestsStepper = RestaurantBookingStepper(counter: counter)
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    func configure(with model: RestaurantBookingViewModel) {
        self.todayDayButton.isSelected = model.today.isSelected
        self.todayDayButton.day = model.today.dayNumber
        self.todayDayButton.dayOfWeek = model.today.shortDayOfWeek
        self.todayDayButton.relativeDay = model.today.dayDescription

        self.tomorrowDayButton.isSelected = model.tomorrow.isSelected
        self.tomorrowDayButton.day = model.tomorrow.dayNumber
        self.tomorrowDayButton.dayOfWeek = model.tomorrow.shortDayOfWeek
        self.tomorrowDayButton.relativeDay = model.tomorrow.dayDescription

        if case .result(let schedule) = model.schedule {
            if model.today.isSelected {
                self.timePickerView.configure(with: delegate?.currentSchedule(schedule: schedule) ?? schedule)
            } else {
                self.timePickerView.configure(with: schedule)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.timePickerView.hideLoading()
            }
        } else {
            self.timePickerView.showLoading()
        }

        self.actionView.isBookingButtonEnabled = false

        self.confirmationButton.isEnabled = false
        self.ofertaCheckboxView.isCheckboxSelected = false
    }

    func resetDaysButtons() {
        self.todayDayButton.isSelected = false
        self.tomorrowDayButton.isSelected = false
    }

    func updateCalendarSelected(day: Date) {
        self.calendarButton.date = day
    }

    // MARK: - Private API

    private func showSuccess() {
        self.bookingContentView.isHidden = true
		self.commentView.text = ""

        self.resultView.alpha = 0.0
        self.resultView.isHidden = false
        self.resultView.state = .success

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.resultView.alpha = 1.0
            }
        )
    }

    private func showError(with text: String?) {
        self.bookingContentView.isHidden = true

        self.resultView.alpha = 0.0
        self.resultView.isHidden = false
        self.resultView.state = .error(text: text)

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.resultView.alpha = 1.0
            }
        )
    }

    @objc
    private func switchDay(_ sender: UIControl) {
        self.todayDayButton.isSelected = sender === self.todayDayButton
        self.tomorrowDayButton.isSelected = sender === self.tomorrowDayButton

        self.delegate?.restaurantBookingView(
            self,
            didSelectDay: sender === self.todayDayButton ? .today : .tomorrow
        )
    }

    @objc
    private func calendarButtonClicked() {
        self.delegate?.restaurantBookingViewDidSelectCalendar(self)
    }

    @objc
    private func confirmationClicked() {
        let isToday = self.todayDayButton.isSelected
        self.delegate?.restaurantBookingViewDidConfirm(self, withComment: self.commentView.text, isToday: isToday)
    }

    @objc
    private func phoneBookingClicked() {
        self.delegate?.restaurantBookingViewDidRequestPhone(self)
    }

    // MARK: - Enums

    enum SelectedShortDay {
        case today
        case tomorrow
    }

    enum State: Equatable {
        enum Reason: Equatable {
            case timeLimit(String)
            case guestsCount
        }

        case idle(String?)
        case phone(Reason)
        case confirmation
        case deposit
        case result(Bool, String?)
    }
}

extension RestaurantBookingView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension RestaurantBookingView: ProgrammaticallyDesignable {
    func setupView() {
        self.guestsStepper.onUpdate = { [weak self] value in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.restaurantBookingView(strongSelf, didSelectGuests: value)
        }

        self.timePickerView.onUpdate = { [weak self] value in
            guard let strongSelf = self else {
                return
            }

            self?.actionView.isBookingButtonEnabled = true
            self?.delegate?.restaurantBookingView(
                strongSelf,
                didSelectTimeIndex: value,
                isToday: strongSelf.todayDayButton.isSelected
            )
        }
    }

    func addSubviews() {
        self.addSubview(self.bookingContentView)
        self.bookingContentView.addSubview(self.guestsStepper)
        self.bookingContentView.addSubview(self.dayButtonsStackView)
        self.bookingContentView.addSubview(self.contentStackView)

		self.addSubview(self.resultView)
    }

    func makeConstraints() {
		self.bookingContentView.make(.edges, .equalToSuperview, [10, 0, 0, 0])

        self.guestsStepper.translatesAutoresizingMaskIntoConstraints = false
        self.guestsStepper.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.guestsStepperInsets.left)
            make.top.equalToSuperview().offset(self.appearance.guestsStepperInsets.top)
        }

        self.dayButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.dayButtonsStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.dayButtonsInsets.right)
            make.top.equalToSuperview().offset(self.appearance.dayButtonsInsets.top)
        }

        [self.todayDayButton, self.tomorrowDayButton, self.calendarButton].forEach { view in
            view.snp.makeConstraints { $0.size.equalTo(self.appearance.dayButtonSize) }
        }

        self.actionView.translatesAutoresizingMaskIntoConstraints = false
        self.actionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.actionViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.actionViewInsets.right)
            make.height.equalTo(self.appearance.actionViewHeight)
        }

        self.confirmationButton.translatesAutoresizingMaskIntoConstraints = false
        self.confirmationButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.actionViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.actionViewInsets.right)
            make.height.equalTo(self.appearance.confirmationButtonHeight)
        }

		self.ofertaCheckboxView.make(.top, .greaterThanOrEqual, to: .bottom, of: self.commentViewContainer, +5)
		self.confirmationButton.make(.top, .greaterThanOrEqual, to: .bottom, of: self.ofertaCheckboxView, +5)

        self.phoneBookingButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.actionViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.actionViewInsets.right)
            make.height.equalTo(self.appearance.actionViewHeight)
        }

        self.timePickerView.translatesAutoresizingMaskIntoConstraints = false
        self.timePickerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.timePickerHeight)
        }

        self.phoneDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.phoneBookingDescriptionInsets.left)
            make.top.equalTo(self.guestsStepper.snp.bottom).offset(self.appearance.phoneBookingDescriptionInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.phoneBookingDescriptionInsets.right)
        }

        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.snp.makeConstraints { make in
			make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.dayButtonsStackView.snp.bottom).offset(self.appearance.timePickerInsets.top)
        }

        self.resultView.translatesAutoresizingMaskIntoConstraints = false
        self.resultView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
