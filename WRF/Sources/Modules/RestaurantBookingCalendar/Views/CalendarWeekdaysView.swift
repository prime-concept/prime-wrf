import UIKit

extension CalendarWeekdaysView {
    struct Appearance {
        let weekdayColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let weekdayFont = UIFont.wrfFont(ofSize: 16)
        let weekendFont = UIFont.wrfFont(ofSize: 16, weight: .medium)
        let weekendEditorLineHeight: CGFloat = 18
    }
}

final class CalendarWeekdaysView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
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

    // MARK: - Private api

    private func makeWeekdayLabel(_ weekday: String, isWeekend: Bool = false) -> UILabel {
        let label = UILabel()
        let font = isWeekend ? self.appearance.weekendFont : self.appearance.weekdayFont
        label.font = font
        label.attributedText = LineHeightStringMaker.makeString(
            weekday,
            editorLineHeight: self.appearance.weekendEditorLineHeight,
            font: font,
            alignment: .center
        )
        label.textColor = self.appearance.weekdayColor
        return label
    }
}

extension CalendarWeekdaysView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.stackView)

        self.stackView.addArrangedSubview(self.makeWeekdayLabel("пн"))
        self.stackView.addArrangedSubview(self.makeWeekdayLabel("вт"))
        self.stackView.addArrangedSubview(self.makeWeekdayLabel("ср"))
        self.stackView.addArrangedSubview(self.makeWeekdayLabel("чт"))
        self.stackView.addArrangedSubview(self.makeWeekdayLabel("пт"))
        self.stackView.addArrangedSubview(self.makeWeekdayLabel("сб", isWeekend: true))
        self.stackView.addArrangedSubview(self.makeWeekdayLabel("вс", isWeekend: true))
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
