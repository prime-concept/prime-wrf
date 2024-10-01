import UIKit

extension CalendarMonthYearView {
    struct Appearance {
        let monthLabelColor = UIColor.black
        let monthLabelEditorLineHeight: CGFloat = 18
        let monthLabelFont = UIFont.wrfFont(ofSize: 16)

        let stackSpacing: CGFloat = 15
    }
}

final class CalendarMonthYearView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.monthYearLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.monthLabelEditorLineHeight,
                font: self.appearance.monthLabelFont
            )
        }
    }

    private(set) lazy var previousMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "calendar-backward").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    private(set) lazy var nextMonthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "calendar-forward").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    private lazy var monthYearLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.monthLabelColor
        label.font = self.appearance.monthLabelFont
        label.text = "Март 2019"
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                self.previousMonthButton, self.monthYearLabel, self.nextMonthButton
            ]
        )
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = self.appearance.stackSpacing
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
}

extension CalendarMonthYearView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
