import SnapKit
import UIKit

protocol RestaurantUnavailableViewDelegate: AnyObject {
    func restaurantUnavailableViewDidRequestCall(_ view: RestaurantUnavailableView)
}

extension RestaurantUnavailableView {
    struct Appearance {
        let descriptionFont = UIFont.wrfFont(ofSize: 15)
        let descriptionEditorLineHeight: CGFloat = 22
        var descriptionTextColor = Palette.shared.textPrimary
        let descriptionInsets = LayoutInsets(top: 25)

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

        let insets = LayoutInsets(left: 15, bottom: 0, right: 15)

        let buttonHeight: CGFloat = 40

        let stackViewInsets = LayoutInsets(top: 10)

        let buttonFont = UIFont.wrfFont(ofSize: 14)
        let buttonInsets = LayoutInsets(top: 30)

        let stackViewSpacing: CGFloat = 10

        let iconSize = CGSize(width: 40, height: 40)
    }
}

final class RestaurantUnavailableView: UIView {
    let appearance: Appearance

    weak var delegate: RestaurantUnavailableViewDelegate?

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

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionFont
        label.textColorThemed = self.appearance.descriptionTextColor
        label.attributedText = LineHeightStringMaker.makeString(
            "В этом ресторане доступно бронирование по телефону",
            editorLineHeight: self.appearance.descriptionEditorLineHeight,
            font: self.appearance.descriptionFont
        )
        label.numberOfLines = 0
        return label
    }()

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

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.daysLabel, self.timeLabel])
        view.axis = .horizontal
        view.spacing = self.appearance.stackViewSpacing
        return view
    }()

    private lazy var bookingButton: ShadowIconButton = {
        var appearance = ShadowIconButton.Appearance()
        appearance.iconSize = self.appearance.iconSize
        appearance.spacing = 0
        let button = ShadowIconButton(appearance: appearance)
        button.title = "Забронировать"
        button.iconImage = #imageLiteral(resourceName: "restaurant-phone")
        button.addTarget(self, action: #selector(self.bookingClicked), for: .touchUpInside)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        let stackViewHeight = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let buttonHeight = self.bookingButton.isHidden ? 0 : self.appearance.buttonHeight
        let buttonTopInset = self.bookingButton.isHidden ? 0 : self.appearance.buttonInsets.top
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.descriptionInsets.top
                    + self.descriptionLabel.intrinsicContentSize.height
                    + self.appearance.stackViewInsets.top
                    + stackViewHeight
                    + buttonTopInset
                    + buttonHeight
                    + self.appearance.insets.bottom
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

    func setBookingButtonVisibility(_ isVisible: Bool) {
        self.bookingButton.isHidden = !isVisible
    }

    // MARK: - Private API

    @objc
    private func bookingClicked() {
        self.delegate?.restaurantUnavailableViewDidRequestCall(self)
    }
}

extension RestaurantUnavailableView: ProgrammaticallyDesignable {
    public func addSubviews() {
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.stackView)
        self.addSubview(self.bookingButton)
    }

    public func makeConstraints() {
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.descriptionInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(self.appearance.stackViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
        }

        self.bookingButton.translatesAutoresizingMaskIntoConstraints = false
        self.bookingButton.snp.makeConstraints { make in
            make.top.equalTo(self.stackView.snp.bottom).offset(self.appearance.buttonInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.buttonHeight)
        }
    }
}
