import SnapKit
import UIKit

protocol RestaurantContactsViewDelegate: AnyObject {
    func restaurantContactsViewDidRequestPhoneCall(_ view: RestaurantContactsView)
    func restaurantContactsViewDidRequestLinkOpen(_ view: RestaurantContactsView)
}

extension RestaurantContactsView {
    struct Appearance {
        let daysFont = UIFont.wrfFont(ofSize: 16)
        let daysEditorLineHeight: CGFloat = 20
        var daysTextColor = Palette.shared.textSecondary
        var daysBackgroundColor = Palette.shared.backgroundColor1
        let daysCornerRadius: CGFloat = 3
        let daysLabelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 1, right: 5)

        let timeFont = UIFont.wrfFont(ofSize: 15)
        let timeEditorLineHeight: CGFloat = 19
        var timeTextColor = Palette.shared.textPrimary
        let timeLabelInsets = LayoutInsets(left: 10)

        let insets = LayoutInsets(top: 15, left: 15, bottom: 0, right: 15)

        let contactsSize = CGSize(width: 40, height: 48)
        var contactButtonColor = Palette.shared.iconsPrimary
        let contactsInset = LayoutInsets(top: 15)
        let contactsSpacing: CGFloat = 15
    }
}

final class RestaurantContactsView: UIView {
    let appearance: Appearance
    weak var delegate: RestaurantContactsViewDelegate?

    private lazy var daysLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = self.appearance.daysFont
        label.textColorThemed = self.appearance.daysTextColor
        label.backgroundColorThemed = self.appearance.daysBackgroundColor
        label.layer.cornerRadius = self.appearance.daysCornerRadius
        label.clipsToBounds = true
        label.insets = self.appearance.daysLabelInsets
        label.isHidden = true
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.timeFont
        label.textColorThemed = self.appearance.timeTextColor
        return label
    }()

    private(set) lazy var linkButton: UIButton = {
        let button = self.makeContactButton(image: #imageLiteral(resourceName: "contacts-link"))
        button.addTarget(self, action: #selector(self.linkButtonClicked), for: .touchUpInside)
        return button
    }()
    private(set) lazy var facebookButton = self.makeContactButton(image: #imageLiteral(resourceName: "contacts-facebook"))
    private(set) lazy var instagramButton = self.makeContactButton(image: #imageLiteral(resourceName: "contacts-instagram"))

    private lazy var numberButton: ShadowButton = {
        let button = ShadowButton()
        button.addTarget(self, action: #selector(self.phoneButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var contactsStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.linkButton])
        view.axis = .horizontal
        return view
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top
                + self.daysLabel.intrinsicContentSize.height
                + self.appearance.contactsSpacing
                + self.appearance.contactsSize.height
                + self.appearance.insets.bottom
        )
    }

    var daysText: String? {
        didSet {
            self.daysLabel.attributedText = LineHeightStringMaker.makeString(
                self.daysText ?? "",
                editorLineHeight: self.appearance.daysEditorLineHeight,
                font: self.appearance.daysFont
            )
            self.daysLabel.isHidden = self.daysText == nil
        }
    }

    var timeText: String? {
        didSet {
            self.timeLabel.attributedText = LineHeightStringMaker.makeString(
                self.timeText ?? "",
                editorLineHeight: self.appearance.timeEditorLineHeight,
                font: self.appearance.timeFont
            )
        }
    }

    var phone: String? {
        didSet {
            self.numberButton.title = self.phone ?? ""
            self.numberButton.isHidden = self.phone == nil
        }
    }

    var site: String? {
        didSet {
            self.contactsStackView.isHidden = self.site == nil
        }
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

    // MARK: - Private API

    private func makeContactButton(image: UIImage?) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColorThemed = self.appearance.contactButtonColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.contactsSize)
        }
        return button
    }

    @objc
    private func phoneButtonClicked() {
        self.delegate?.restaurantContactsViewDidRequestPhoneCall(self)
    }

    @objc
    private func linkButtonClicked() {
        self.delegate?.restaurantContactsViewDidRequestLinkOpen(self)
    }
}

extension RestaurantContactsView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.daysLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.contactsStackView)
        self.addSubview(self.numberButton)
    }

    func makeConstraints() {
        self.daysLabel.translatesAutoresizingMaskIntoConstraints = false
        self.daysLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.daysLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
        }

        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.daysLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.leading.equalTo(self.daysLabel.snp.trailing).offset(self.appearance.timeLabelInsets.left)
        }

        self.contactsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.contactsStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            make.height.equalTo(self.appearance.contactsSize.height)
        }

        self.numberButton.translatesAutoresizingMaskIntoConstraints = false
        self.numberButton.snp.makeConstraints { make in
            make.leading.equalTo(self.contactsStackView.snp.trailing).offset(self.appearance.contactsSpacing)
            make.centerY.equalTo(self.contactsStackView.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.contactsSize.height)
        }
    }
}
