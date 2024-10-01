import Nuke
import SnapKit
import UIKit

extension MapRestaurantItemView {
    struct Appearance {
        let cornerRadius: CGFloat = 10
        let dimColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)

        let nameFont = UIFont.wrfFont(ofSize: 20)
        let nameInsets = LayoutInsets(top: 9, left: 10, right: 10)
        let logoInsets = LayoutInsets(top: 8, left: 12, bottom: 8)
        let logoWidth = 120.0
        let logoHeight = 50.0
        let nameTextColor = UIColor.white
        let nameEditorLineHeight: CGFloat = 23

        let distanceIconSize = CGSize(width: 9, height: 9)
        let distanceTextColor = UIColor.white.withAlphaComponent(0.8)
        let distanceFont = UIFont.wrfFont(ofSize: 13)
        let distanceLineHeight: CGFloat = 15

        let distanceIconLabelSpacing: CGFloat = 8
        let distanceInsets = LayoutInsets(top: 16, right: 10)

        let priceFont = UIFont.wrfFont(ofSize: 12)
        let priceTextColor = UIColor.white.withAlphaComponent(0.8)
        let priceInsets = LayoutInsets(top: 5, right: 10)
        let priceLineHeight: CGFloat = 14

        let badgeFont = UIFont.wrfFont(ofSize: 7, weight: .bold)
        let badgeTextColor = UIColor.white
        let badgeEditorLineHeight: CGFloat = 8
        let badgeInsets = LayoutInsets(top: 10, left: 10, bottom: 10, right: 10)
        let badgePaddingInsets = UIEdgeInsets(top: 8, left: 7, bottom: 8, right: 7)
        let twoLinesBadgePaddingInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)
        let badgeBorderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
        let badgeCornerRadius: CGFloat = 5

        let ratingStarFilledColor = Palette.shared.white
        let ratingStarClearColor = Palette.shared.white.withAlphaComponent(0.5)
        let ratingStarsSpacing: CGFloat = 3
        let ratingStarsSize = CGSize(width: 12, height: 11)

        let ratingFont = UIFont.wrfFont(ofSize: 12)
        let ratingTextColor = UIColor.white.withAlphaComponent(0.8)
        let ratingLineHeight: CGFloat = 14

        let ratingInsets = LayoutInsets(top: 5, left: 10)
        let ratingStarsLabelSpacing: CGFloat = 8

        let timeFont = UIFont.wrfFont(ofSize: 13)
        var timeTextColor = UIColor.black
        var timeBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.9)
        let timeInsets = UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6)
        let smallTimeInsets = UIEdgeInsets(top: 5, left: 6, bottom: 5, right: 6)
        let timeStackViewInsets = LayoutInsets(top: 10, left: 10, bottom: 10, right: 10)

        let separatorWidth: CGFloat = 1.0
        let borderWidth: CGFloat = 1.0
        let separatorColor = UIColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.0)
    }
}

final class MapRestaurantItemView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.dimColor
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameFont
        label.textColor = self.appearance.nameTextColor
        return label
    }()

    private lazy var distanceIconImageView: UIImageView = {
        let image = #imageLiteral(resourceName: "restaurant-item-distance").withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.distanceTextColor
        return imageView
    }()

    private lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.distanceFont
        label.textColor = self.appearance.distanceTextColor
        return label
    }()

    private lazy var distanceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.distanceIconImageView, self.distanceLabel])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.distanceIconLabelSpacing
        stackView.alignment = .center
        return stackView
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.priceFont
        label.textColor = self.appearance.priceTextColor
        return label
    }()

    private lazy var ratingView: StarsRatingView = {
        let appearance = StarsRatingView.Appearance(
            starFilledColor: self.appearance.ratingStarFilledColor,
            starClearColor: self.appearance.ratingStarClearColor,
            starsSpacing: self.appearance.ratingStarsSpacing,
            starsSize: self.appearance.ratingStarsSize,
            starsImage: #imageLiteral(resourceName: "restaurant-item-star")
        )
        let view = StarsRatingView(appearance: appearance)
        return view
    }()

    private lazy var badgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textColor = self.appearance.badgeTextColor
        label.font = self.appearance.badgeFont
        label.numberOfLines = 0
        label.insets = self.appearance.badgePaddingInsets
        label.isHidden = true

        label.layer.borderWidth = 1
        label.layer.cornerRadius = self.appearance.badgeCornerRadius
        label.layer.borderColor = self.appearance.badgeBorderColor

        return label
    }()

    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.ratingFont
        label.textColor = self.appearance.ratingTextColor
        return label
    }()

    private lazy var ratingStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.ratingView, self.ratingLabel])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.ratingStarsLabelSpacing
        stackView.alignment = .center
        return stackView
    }()

    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    /// Use small time labels (for small device width)
    var isSmall = false

    var title: String? {
        didSet {
            self.nameLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.nameEditorLineHeight,
                font: self.appearance.nameFont,
                lineBreakMode: .byTruncatingTail
            )
        }
    }

    var price: String? {
        didSet {
            self.priceLabel.attributedText = LineHeightStringMaker.makeString(
                self.price ?? "",
                editorLineHeight: self.appearance.priceLineHeight,
                font: self.appearance.priceFont
            )
        }
    }

    var distance: String? {
        didSet {
            self.distanceStackView.isHidden = self.distance == nil
            self.distanceLabel.attributedText = LineHeightStringMaker.makeString(
                self.distance ?? "",
                editorLineHeight: self.appearance.distanceLineHeight,
                font: self.appearance.distanceFont
            )
        }
    }

    var deliveryTime: String? {
        didSet {
            self.distanceIconImageView.isHidden = true
            self.distanceLabel.attributedText = LineHeightStringMaker.makeString(
                self.deliveryTime ?? "",
                editorLineHeight: self.appearance.distanceLineHeight,
                font: self.appearance.distanceFont
            )
        }
    }

    var ratingText: String? {
        didSet {
            self.ratingLabel.attributedText = LineHeightStringMaker.makeString(
                self.ratingText ?? "",
                editorLineHeight: self.appearance.ratingLineHeight,
                font: self.appearance.ratingFont
            )
        }
    }

    var rating = 0 {
        didSet {
            self.ratingView.starsCount = self.rating
        }
    }

    var isRatingHidden: Bool = false {
        didSet {
            self.ratingStackView.isHidden = self.isRatingHidden
        }
    }

    var imageURL: URL? {
        didSet {
            guard let url = self.imageURL else {
                self.imageView.image = nil
                return
            }

            Nuke.loadImage(with: url, into: self.imageView)
        }
    }

    // TODO: - Set logo for "MeisonDellos" target.
    var logoURL: URL? {
        didSet {
            guard let url = self.logoURL else {
                logoImageView.image = nil
                return
            }

            Nuke.loadImage(with: url, into: logoImageView)
        }
    }

    private var timeLabels: [String] = []
    private var latestBoundsForTimeLabelsLayout: CGRect?

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        let showsLogo = PGCMain.shared.featureFlags.map.showRestaurantLogo

        nameLabel.isHidden = showsLogo
        ratingStackView.isHidden = showsLogo
        priceLabel.isHidden = showsLogo
        logoImageView.isHidden = !showsLogo
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutTimeLabels(self.timeLabels)
    }

    func addTimeLabels(_ labels: [String], hasDelivery: Bool, isClosed: Bool) {
        var shouldShowBadge = false
        if isClosed {
            self.badgeLabel.attributedText = LineHeightStringMaker.makeString(
                "Ресторан временно\nзакрыт для посещения".uppercased(),
                editorLineHeight: self.appearance.badgeEditorLineHeight,
                font: self.appearance.badgeFont
            )
            self.badgeLabel.insets = self.appearance.twoLinesBadgePaddingInsets
            shouldShowBadge = true
        } else if hasDelivery {
            self.badgeLabel.attributedText = LineHeightStringMaker.makeString(
                "Доставка".uppercased(),
                editorLineHeight: self.appearance.badgeEditorLineHeight,
                font: self.appearance.badgeFont
            )
            shouldShowBadge = true
        }

        self.timeLabels = labels
        self.badgeLabel.isHidden = !shouldShowBadge

        self.timeStackView.snp.remakeConstraints { make in
            make.top.equalTo(self.ratingStackView.snp.bottom).offset(self.appearance.timeStackViewInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.timeStackViewInsets.bottom)
            if shouldShowBadge {
                make.leading.greaterThanOrEqualTo(self.badgeLabel.snp.trailing)
                    .offset(self.appearance.badgeInsets.right)
            } else {
                make.leading.equalToSuperview().offset(self.appearance.timeStackViewInsets.left)
            }

            make.trailing.equalToSuperview().offset(-self.appearance.timeStackViewInsets.right)
        }
    }

    func clear() {
        self.nameLabel.attributedText = nil
        self.ratingLabel.attributedText = nil
        self.distanceLabel.attributedText = nil
        self.priceLabel.attributedText = nil
        self.ratingView.starsCount = 0
        self.imageView.image = nil
        self.addTimeLabels([], hasDelivery: false, isClosed: false)
    }

    // MARK: - Private API

    private func makeTimeLabel(_ time: String) -> PaddingLabel {
        let label = PaddingLabel()
        label.font = self.appearance.timeFont
        label.textColor = self.appearance.timeTextColor
        label.backgroundColor = self.appearance.timeBackgroundColor
        label.text = time

        if self.isSmall {
            label.insets = self.appearance.smallTimeInsets
        } else {
            label.insets = self.appearance.timeInsets
        }
        label.textAlignment = .center
        return label
    }

    private func makeBookingLabel() -> PaddingLabel {
        let bookingLabel = PaddingLabel()
        bookingLabel.textColor = self.appearance.badgeTextColor
        bookingLabel.font = self.appearance.badgeFont
        bookingLabel.numberOfLines = 0
        bookingLabel.backgroundColor = .clear
        bookingLabel.insets = self.appearance.badgePaddingInsets
        bookingLabel.text = "Бронирование".uppercased()
        bookingLabel.textAlignment = .center

        bookingLabel.layer.borderWidth = 1
        bookingLabel.layer.borderColor = self.appearance.badgeBorderColor

        return bookingLabel
    }

    private func layoutTimeLabels(_ labels: [String]) {
        defer { latestBoundsForTimeLabelsLayout = bounds }

        if latestBoundsForTimeLabelsLayout == bounds {
            return
        }
        
        self.timeStackView.removeAllArrangedSubviews()

        if labels.isEmpty {
            return
        }

        let badgeWidth = ceil(self.badgeLabel.intrinsicContentSize.width + self.appearance.badgeInsets.right)
        var maxTimeStackViewWidth = self.bounds.width
            - self.appearance.timeStackViewInsets.left
            - self.appearance.timeStackViewInsets.right
            - (self.badgeLabel.isHidden ? 0 : badgeWidth)

        var timeLabels: [UILabel] = []
        if !self.timeLabels.isEmpty {
            let bookingLabel = self.makeBookingLabel()
            bookingLabel.translatesAutoresizingMaskIntoConstraints = false
            bookingLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            bookingLabel.setContentHuggingPriority(.required, for: .horizontal)

            timeLabels.append(bookingLabel)
            maxTimeStackViewWidth -= ceil(bookingLabel.intrinsicContentSize.width)
        }
        timeLabels += self.timeLabels.map(self.makeTimeLabel)

        let timeLabelWidth = ceil(timeLabels.last?.intrinsicContentSize.width ?? 1)
        let countToFit = min(
            Int(maxTimeStackViewWidth / (timeLabelWidth + self.appearance.separatorWidth)),
            max(0, timeLabels.count - 1)
        )
        let oneLabelWidth = floor(
            (maxTimeStackViewWidth - CGFloat(countToFit - 1) * self.appearance.separatorWidth) / CGFloat(countToFit)
        )

        if timeLabels.count >= 2 {
            timeLabels.suffix(from: 1).forEach { label in
                label.snp.makeConstraints { make in
                    make.width.equalTo(oneLabelWidth)
                }
            }
        }

        if countToFit > 0 {
            let labels = Array(timeLabels.prefix(countToFit + 1))
            for (index, timeLabel) in labels.enumerated() {
                self.timeStackView.addArrangedSubview(timeLabel)
                if index < (labels.count - 1), index > 0 {
                    let separatorView = UIView()
                    separatorView.backgroundColor = self.appearance.separatorColor
                    separatorView.snp.makeConstraints { make in
                        make.width.equalTo(self.appearance.separatorWidth)
                    }

                    self.timeStackView.addArrangedSubview(separatorView)
                }

                if index == 0 || index == labels.count - 1 {
                    timeLabel.layer.masksToBounds = true
                    timeLabel.layer.cornerRadius = self.appearance.badgeCornerRadius
                    if #available(iOS 11.0, *) {
                        timeLabel.layer.maskedCorners = index == 0
                            ? [.layerMinXMaxYCorner, .layerMinXMinYCorner]
                            : [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
                    }
                }
            }
        }
    }
}

extension MapRestaurantItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius - 2

        self.badgeLabel.layer.borderWidth = 1
        self.badgeLabel.layer.cornerRadius = self.appearance.badgeCornerRadius
        self.badgeLabel.layer.borderColor = self.appearance.badgeBorderColor
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.dimView)
        addSubview(logoImageView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.distanceStackView)
        self.addSubview(self.priceLabel)
        self.addSubview(self.ratingStackView)
        self.addSubview(self.badgeLabel)
        self.addSubview(self.timeStackView)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.distanceStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.distanceInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.distanceInsets.right)
        }
        self.distanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.distanceStackView.setContentCompressionResistancePriority(.required, for: .horizontal)

        if PGCMain.shared.featureFlags.map.showRestaurantLogo {
            logoImageView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(self.appearance.logoInsets.left)
                $0.top.equalToSuperview().offset(self.appearance.logoInsets.top)
                $0.width.equalTo(appearance.logoWidth)
                $0.height.equalTo(appearance.logoHeight)
            }
        } else {
            self.nameLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(self.appearance.nameInsets.left)
                make.top.equalToSuperview().offset(self.appearance.nameInsets.top)
                make.trailing
                    .lessThanOrEqualTo(self.distanceStackView.snp.leading)
                    .offset(-self.appearance.nameInsets.right)
            }
        }

        self.distanceIconImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.distanceIconSize)
        }

        self.priceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.distanceStackView.snp.bottom).offset(self.appearance.priceInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.priceInsets.right)
        }

        self.ratingStackView.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.ratingInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.ratingInsets.left)
        }

        self.badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.badgeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.ratingStackView.snp.bottom).offset(self.appearance.badgeInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.badgeInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.badgeInsets.bottom)
        }

        self.timeStackView.snp.makeConstraints { make in
            make.top.equalTo(self.ratingStackView.snp.bottom).offset(self.appearance.timeStackViewInsets.top)
            make.leading.greaterThanOrEqualTo(self.badgeLabel.snp.trailing).offset(self.appearance.badgeInsets.right)
            make.trailing.equalToSuperview().offset(-self.appearance.timeStackViewInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.timeStackViewInsets.bottom)
        }

        self.timeStackView.setContentHuggingPriority(.required, for: .horizontal)
        self.timeStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
