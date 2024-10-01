import SnapKit
import UIKit

extension RestaurantReviewItemView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 13)
        var titleTextColor = UIColor.black
        let titleEditorLineHeight: CGFloat = 16
        let titleInsets = LayoutInsets(top: 10, left: 10, bottom: 0, right: 15)

        let subtitleFont = UIFont.wrfFont(ofSize: 11)
        var subtitleTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let subtitleEditorLineHeight: CGFloat = 13

        let reviewFont = UIFont.wrfFont(ofSize: 12)
        var reviewTextColor = UIColor.black
        let reviewEditorLineHeight: CGFloat = 17
        let reviewInsets = LayoutInsets(top: 10, left: 10, bottom: 8, right: 10)

        var backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)

        let avatarSize = CGSize(width: 30, height: 30)
        let avatarInsets = LayoutInsets(top: 10, left: 10)

        let starsSpacing: CGFloat = 3
        let starsSize = CGSize(width: 10, height: 10)
        let starsInsets = LayoutInsets(left: 15, right: 15)
        var starFilledColor = Palette.shared.iconsBrand
        var starColor = Palette.shared.iconsSecondary
    }
}

final class RestaurantReviewItemView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = self.appearance.avatarSize.height / 2
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleFont
        label.textColor = self.appearance.subtitleTextColor
        return label
    }()

    private lazy var ratingView: StarsRatingView = {
        var appearance = StarsRatingView.Appearance()
        appearance.starClearColor = self.appearance.starColor
        appearance.starFilledColor = self.appearance.starFilledColor
        appearance.starsSize = self.appearance.starsSize
        appearance.starsSpacing = self.appearance.starsSpacing
        appearance.starsImage = #imageLiteral(resourceName: "restaurant-item-star-rating")
        let view = StarsRatingView(appearance: appearance)
        return view
    }()

    private lazy var reviewLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.reviewFont
        label.textColor = self.appearance.reviewTextColor
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        return label
    }()

    var image: UIImage? {
        didSet {
            self.avatarImageView.image = self.image
        }
    }

    var name: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.name ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont
            )
        }
    }

    var date: String? {
        didSet {
            self.subtitleLabel.attributedText = LineHeightStringMaker.makeString(
                self.date ?? "",
                editorLineHeight: self.appearance.subtitleEditorLineHeight,
                font: self.appearance.subtitleFont
            )
        }
    }

    var rating = 0 {
        didSet {
            self.ratingView.starsCount = self.rating
        }
    }

    var review: String? {
        didSet {
            self.reviewLabel.attributedText = LineHeightStringMaker.makeString(
                self.review ?? "",
                editorLineHeight: self.appearance.reviewEditorLineHeight,
                font: self.appearance.reviewFont
            )
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
}

extension RestaurantReviewItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.reviewLabel)
        self.addSubview(self.ratingView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.avatarSize)
            make.leading.equalToSuperview().offset(self.appearance.avatarInsets.left)
            make.top.equalToSuperview().offset(self.appearance.avatarInsets.top)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleInsets.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.titleInsets.left)
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.titleInsets.bottom)
            make.leading.equalTo(self.titleLabel.snp.leading)
        }

        self.reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        self.reviewLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.reviewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.reviewInsets.right)
            make.top.equalTo(self.avatarImageView.snp.bottom).offset(self.appearance.reviewInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.reviewInsets.bottom)
        }

        self.ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.ratingView.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.starsInsets.right)
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.starsInsets.left)
        }
    }
}
