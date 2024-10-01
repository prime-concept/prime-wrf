import SnapKit
import UIKit

extension FeedbackRateView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 18)
        var titleTextColor = UIColor.black
        let titleEditorLineHeight: CGFloat = 21
        let titleInsets = LayoutInsets(top: 42, left: 15, right: 15)

        let starSize = CGSize(width: 35, height: 35)
        let starsSpacing: CGFloat = 20
        var starFilledColor = Palette.shared.iconsBrand
        var starClearColor = Palette.shared.iconsSecondary
        let ratingViewInsets = LayoutInsets(top: 15, bottom: 7)
    }
}

final class FeedbackRateView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.attributedText = LineHeightStringMaker.makeString(
            "Оцените ресторан",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont,
            alignment: .center
        )
        label.textColor = self.appearance.titleTextColor
        return label
    }()

    private(set) lazy var starsRatingView: StarsRatingView = {
        let appearance = StarsRatingView.Appearance(
            starFilledColor: self.appearance.starFilledColor,
            starClearColor: self.appearance.starClearColor,
            starsSpacing: self.appearance.starsSpacing,
            starsSize: self.appearance.starSize,
            starsImage: #imageLiteral(resourceName: "restaurant-item-star-rating")
        )
        let ratingView = StarsRatingView(appearance: appearance)
        ratingView.isUserInteractionEnabled = true
        ratingView.starsCount = 5
        return ratingView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.titleInsets.top
                + self.titleLabel.intrinsicContentSize.height
                + self.appearance.ratingViewInsets.top
                + self.starsRatingView.intrinsicContentSize.height
                + self.appearance.ratingViewInsets.bottom
        )
    }

    var restaurantName: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                "Оцените ресторан \(self.restaurantName ?? "")",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont,
                alignment: .center
            )
        }
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension FeedbackRateView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.starsRatingView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.titleInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.starsRatingView.translatesAutoresizingMaskIntoConstraints = false
        self.starsRatingView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.ratingViewInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.ratingViewInsets.bottom)
        }
    }
}
