import SnapKit
import UIKit

extension AuthConfirmationControlsView {
    struct Appearance {
        let descriptionFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let descriptionTextColor = Palette.shared.textSecondary
        let descriptionEditorLineHeight: CGFloat = 18
        let descriptionInsets = LayoutInsets(top: 15, bottom: 25)

        let buttonFont = UIFont.wrfFont(ofSize: 14)
        let buttonEditorLineHeight: CGFloat = 16
        let buttonSize = CGSize(width: 185, height: 40)

        let termsFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let termsColor = Palette.shared.textSecondary
        let termsInsets = LayoutInsets(top: 35, bottom: 15)

        var shouldUsePrivacyPolicy = true
    }
}

final class AuthConfirmationControlsView: UIView {
    let appearance: Appearance

    var isTermsEnabled: Bool = true {
        didSet {
            if !self.isTermsEnabled {
                self.termsTextView.removeFromSuperview()
            }
        }
    }

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Введите номер телефона, на который вам придет SMS с кодом для входа в личный кабинет",
            editorLineHeight: self.appearance.descriptionEditorLineHeight,
            font: self.appearance.descriptionFont
        )
        label.textColorThemed = self.appearance.descriptionTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var termsTextView: UITextView = {
        let view = UITextView()

        view.delegate = self
        view.dataDetectorTypes = .link
        view.isEditable = false
        view.isSelectable = true
        view.isScrollEnabled = false

        let termsText = "Пользовательское соглашение"
        let termsRange = NSRange(location: 51, length: 27)
        let attributedString = NSMutableAttributedString(string: "Нажимая кнопку “Получить код в SMS”, Вы принимаете \(termsText)")
        attributedString.addAttributes(
            [
                .link: PGCMain.shared.config.termsOfUseURL,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: self.appearance.termsColor
            ],
            range: termsRange
        )

        attributedString.addAttributes(
            [.foregroundColor: self.appearance.termsColor, .font: self.appearance.termsFont],
            range: NSRange(location: 0, length: 78)
        )

        if self.appearance.shouldUsePrivacyPolicy {
            let conditionsText = "Политику конфиденциальности"
            let conditionsRange = NSRange(location: 81, length: 27)

            attributedString.append(NSMutableAttributedString(string: " и \(conditionsText)"))
            attributedString.addAttributes(
                [
                    .link: PGCMain.shared.config.privacyPolicyURL,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: self.appearance.termsColor
                ],
                range: conditionsRange
            )

            attributedString.addAttributes(
                [.foregroundColor: self.appearance.termsColor, .font: self.appearance.termsFont],
                range: NSRange(location: 78, length: 30)
            )
        }

        view.attributedText = attributedString
        view.linkTextAttributes = [
            .foregroundColor: self.appearance.termsColor
        ]
        view.backgroundColorThemed = Palette.shared.clear

        return view
    }()

    private(set) lazy var submitButton: UIControl = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.buttonFont
        appearance.mainEditorLineHeight = self.appearance.buttonEditorLineHeight
        let button = ShadowButton(appearance: appearance)
        button.title = "Получить код в SMS"
        return button
    }()

    override var intrinsicContentSize: CGSize {
        let termsHeight = self.appearance.termsInsets.top
            + self.termsTextView.intrinsicContentSize.height
            + self.appearance.termsInsets.bottom
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.descriptionInsets.top
                + self.descriptionLabel.intrinsicContentSize.height
                + self.appearance.descriptionInsets.bottom
                + self.appearance.buttonSize.height
                + (self.isTermsEnabled ? termsHeight : 0)
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension AuthConfirmationControlsView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.submitButton)
        self.addSubview(self.termsTextView)
    }

    func makeConstraints() {
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.descriptionInsets.top)
        }

        self.submitButton.translatesAutoresizingMaskIntoConstraints = false
        self.submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(self.appearance.buttonSize)
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(self.appearance.descriptionInsets.bottom)
        }

        self.termsTextView.translatesAutoresizingMaskIntoConstraints = false
        self.termsTextView.snp.makeConstraints { make in
            make.top.equalTo(self.submitButton.snp.bottom).offset(self.appearance.termsInsets.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.termsInsets.bottom)
        }
    }
}

extension AuthConfirmationControlsView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }
}
