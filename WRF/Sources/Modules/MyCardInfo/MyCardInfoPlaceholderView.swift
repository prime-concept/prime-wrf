import SnapKit

extension MyCardInfoPlaceholderView {
    struct Appearance {
        let textColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let font = UIFont.wrfFont(ofSize: 13, weight: .light)
        let editorLineHeight: CGFloat = 18
        let horizontalInset: CGFloat = 24
    }
}

final class MyCardInfoPlaceholderView: UIView {
    let appearance: Appearance

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.textColor
        label.font = self.appearance.font
        // swiftlint:disable line_length
        label.attributedText = LineHeightStringMaker.makeString(
            """
                Скоро здесь будет доступна ваша программа лояльности. Копите бонусы от заказов в любимых ресторанах и расплачивайтесь ими при следующих покупках.
                """,
            editorLineHeight: self.appearance.editorLineHeight,
            font: self.appearance.font
        )
        // swiftlint:enable line_length
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    init(frame: CGRect, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyCardInfoPlaceholderView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.placeholderLabel)
    }

    func makeConstraints() {
        self.placeholderLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(self.appearance.horizontalInset)
            make.centerY.equalToSuperview()
        }
    }
}

