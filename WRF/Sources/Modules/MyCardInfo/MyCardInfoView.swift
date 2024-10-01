import SnapKit
import UIKit

extension MyCardInfoView {
    struct Appearance {
        let backgroundColor = Palette.shared.backgroundColor0

        let separatorColor = Palette.shared.strokeSecondary
        let separatorHeight: CGFloat = 1

        let cardPaymentViewInsets = LayoutInsets(top: 20, left: 15, right: 15)
        let cardDescriptionLabelInsets = LayoutInsets(top: 25, left: 25, right: 25)
        let qrCodeSecurityLabelInsets = LayoutInsets(top: 25, left: 15, right: 15)

        let cardPaymentViewHeight: CGFloat = 50

        var descriptionLabelTextColor = Palette.shared.textPrimary
        let descriptionLabelFont = UIFont.wrfFont(ofSize: 13, weight: .light)
        let descriptionLabelEditorLineHeight: CGFloat = 18

        let securityLabelTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let securityLabelFont = UIFont.wrfFont(ofSize: 13, weight: .light)
        let securityLabelEditorLineHeight: CGFloat = 18

        var rulesLabelTextColor = Palette.shared.textPrimary
        let rulesLabelFont = UIFont.wrfFont(ofSize: 13, weight: .light)
        let rulesLabelEditorLineHeight: CGFloat = 16
        let rulesLabelTopOffset: CGFloat = 20

        var underlineColor = Palette.shared.strokePrimary
        let underlineHeight: CGFloat = 1

        var cardHeaderHeight: CGFloat = 64
        var cardHeaderLogo = #imageLiteral(resourceName: "dark-logo")
        let cardHeaderTopOffset: CGFloat = 20

        let bottomSeparatorTopOffset: CGFloat = 20

        let rulesButtonTapAreaHeight: CGFloat = 44
    }
}

final class MyCardInfoView: UIView {
    let appearance: Appearance

    var balance: String? {
        didSet {
            self.cardHeaderView.balance = self.balance
        }
    }

    var gradeName: String? {
        didSet {
            self.cardPaymentView.myCardInfoTypeView.gradeName = self.gradeName
        }
    }

    var userImage: UIImage? {
        didSet {
            self.cardPaymentView.myCardInfoTypeView.userImage = self.userImage
        }
    }

    var descriptionText: String? {
        didSet {
            self.cardDescriptionLabel.attributedText = LineHeightStringMaker.makeString(
                self.descriptionText ?? "",
                editorLineHeight: self.appearance.descriptionLabelEditorLineHeight,
                font: self.appearance.descriptionLabelFont
            )
        }
    }

    private lazy var cardHeaderView = CardHeaderView()

    private lazy var cardPaymentView = MyCardInfoCardView()

    private lazy var cardDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColorThemed = self.appearance.descriptionLabelTextColor
        label.font = self.appearance.descriptionLabelFont
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var qrCodeSecurityLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.securityLabelTextColor
        label.font = self.appearance.securityLabelFont
        // swiftlint:disable line_length
        label.attributedText = LineHeightStringMaker.makeString(
                """
                QR-код постоянно обновляется. Не пытайтесь его скопировать или передать третьим лицам. Бонусы начисляются только держателям карт лояльности.
                """,
                editorLineHeight: self.appearance.securityLabelEditorLineHeight,
                font: self.appearance.securityLabelFont
        )
        // swiftlint:enable line_length
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var rulesLabel: UILabel = {
        let label = UILabel()
        label.textColorThemed = self.appearance.rulesLabelTextColor
        label.font = self.appearance.rulesLabelFont

        let text = LineHeightStringMaker.makeString(
            "Правила программы",
            editorLineHeight: self.appearance.rulesLabelEditorLineHeight,
            font: self.appearance.rulesLabelFont
        )
        label.attributedText = text

        let underlineView = UIView()
        label.addSubview(underlineView)
        underlineView.backgroundColorThemed = self.appearance.underlineColor
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        underlineView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.underlineHeight)
        }
        return label
    }()

    private lazy var rulesTransitionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.backgroundColor = .clear
        button.setTitle(nil, for: .normal)
        button.addTarget(self, action: #selector(self.rulesButtonClicked), for: .touchUpInside)
        return button
    }()

    var onRulesLinkClick: (() -> Void)?

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
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

    // MARK: - Private api

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColorThemed = appearance.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
        return view
    }

    @objc
    private func rulesButtonClicked() {
        self.onRulesLinkClick?()
    }
}

extension MyCardInfoView: ProgrammaticallyDesignable {
    func setupView() {
        backgroundColorThemed = appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.cardHeaderView)
        self.addSubview(self.cardPaymentView)
        self.addSubview(self.cardDescriptionLabel)
        self.addSubview(self.qrCodeSecurityLabel)
        self.addSubview(self.rulesLabel)
        self.addSubview(self.rulesTransitionButton)
    }

    func makeConstraints() {
        self.cardHeaderView.translatesAutoresizingMaskIntoConstraints = false
        self.cardHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.cardHeaderTopOffset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.cardHeaderHeight)
        }

        let topSeparator = self.makeSeparator()
        self.addSubview(topSeparator)
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        topSeparator.snp.makeConstraints { make in
            make.top.equalTo(self.cardHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.cardPaymentView.translatesAutoresizingMaskIntoConstraints = false
        self.cardPaymentView.snp.makeConstraints { make in
            make.top
                .equalTo(topSeparator.snp.bottom)
                .offset(self.appearance.cardPaymentViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.cardPaymentViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.cardPaymentViewInsets.right)
            make.height.equalTo(self.appearance.cardPaymentViewHeight)
        }

        self.cardDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardDescriptionLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.cardPaymentView.snp.bottom)
                .offset(self.appearance.cardDescriptionLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.cardDescriptionLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.cardDescriptionLabelInsets.right)
        }

        let bottomSeparator = self.makeSeparator()
        self.addSubview(bottomSeparator)
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.snp.makeConstraints { make in
            make.top
                .equalTo(self.cardDescriptionLabel.snp.bottom)
                .offset(self.appearance.bottomSeparatorTopOffset)
            make.leading.trailing.equalToSuperview()
        }

        self.qrCodeSecurityLabel.translatesAutoresizingMaskIntoConstraints = false
        self.qrCodeSecurityLabel.snp.makeConstraints { make in
            make.top
                .equalTo(bottomSeparator.snp.bottom)
                .offset(self.appearance.qrCodeSecurityLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.qrCodeSecurityLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.qrCodeSecurityLabelInsets.right)
        }

        self.rulesLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rulesLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top
                .equalTo(self.qrCodeSecurityLabel.snp.bottom)
                .offset(self.appearance.rulesLabelTopOffset)
        }

        self.rulesTransitionButton.translatesAutoresizingMaskIntoConstraints = false
        self.rulesTransitionButton.snp.makeConstraints { make in
            make.center.equalTo(self.rulesLabel)
            make.height.equalTo(self.appearance.rulesButtonTapAreaHeight)
            make.width.equalTo(self.rulesLabel)
        }
    }
}
