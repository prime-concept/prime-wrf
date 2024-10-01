import SnapKit
import UIKit

extension RestaurantBookingCheckoutAgreementView {
    struct Appearance {
		let checkboxInsets = LayoutInsets(top: -5, left: 27, right: 15)

        let agreementFont = UIFont.wrfFont(ofSize: 13, weight: .light)
        var agreementTextColor = UIColor.black
        let agreementEditorLineHeight: CGFloat = 16
        let agreementInsets = LayoutInsets(top: 2, left: 5)
    }
}

final class RestaurantBookingCheckoutAgreementView: UIView {
    let appearance: Appearance

    private lazy var checkboxControl = CheckboxControl(isSelected: self.isCheckboxSelected)

    private lazy var fakeLinkButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setBackgroundImage(UIImage(), for: .normal)
        button.addTarget(self, action: #selector(self.onToSLinkClicked), for: .touchUpInside)
        return button
    }()

    private lazy var agreementLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.agreementFont

        let text = LineHeightStringMaker.makeString(
            "Ознакомлен с правилами бронирования",
            editorLineHeight: self.appearance.agreementEditorLineHeight,
            font: self.appearance.agreementFont
        )

        // TODO: Just add UIButton with target above this label and handle click to URL redirect
        let range = NSRange(location: 13, length: 22)
        text.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        text.addAttribute(.underlineColor, value: self.appearance.agreementTextColor, range: range)

        label.attributedText = text
        label.textColor = self.appearance.agreementTextColor
        label.numberOfLines = 0
        return label
    }()

    var isCheckboxSelected = false {
        didSet {
            self.checkboxControl.isSelected = self.isCheckboxSelected
        }
    }

    var onChange: ((Bool) -> Void)? {
        didSet {
            self.checkboxControl.onChange = self.onChange
        }
    }

    var onLinkClick: (() -> Void)?

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

    @objc
    private func onToSLinkClicked() {
        self.onLinkClick?()
    }
}

extension RestaurantBookingCheckoutAgreementView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.checkboxControl)
        self.addSubview(self.agreementLabel)
        self.addSubview(self.fakeLinkButton)
    }

    func makeConstraints() {
        self.checkboxControl.translatesAutoresizingMaskIntoConstraints = false
        self.checkboxControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.checkboxInsets.top)
			make.bottom.equalToSuperview()
			make.height.width.equalTo(20)
			make.trailing.equalToSuperview().offset(-self.appearance.checkboxInsets.right)
        }

        self.agreementLabel.translatesAutoresizingMaskIntoConstraints = false
        self.agreementLabel.snp.makeConstraints { make in
            make.top.equalTo(self.checkboxControl.snp.top).offset(self.appearance.agreementInsets.top)
			make.bottom.greaterThanOrEqualToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.agreementInsets.left)
            make.trailing.equalTo(self.checkboxControl.snp.leading).offset(-self.appearance.checkboxInsets.left)
        }

        self.fakeLinkButton.snp.makeConstraints { make in
            make.size.equalTo(self.agreementLabel)
            make.center.equalTo(self.agreementLabel)
        }
    }
}
