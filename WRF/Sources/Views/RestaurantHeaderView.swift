import Nuke
import SnapKit
import UIKit

extension RestaurantHeaderView {
    struct Appearance {
        let nameFont = UIFont.wrfFont(ofSize: 25)
        let nameInsets = LayoutInsets(left: 14, right: 14)
        let nameTextColor = UIColor.white
        let nameEditorLineHeight: CGFloat = 29

        let distanceIconSize = CGSize(width: 9, height: 9)
        let distanceTextColor = UIColor.white.withAlphaComponent(0.8)
        let distanceFont = UIFont.wrfFont(ofSize: 13)
        let distanceLineHeight: CGFloat = 15

        let distanceIconLabelSpacing: CGFloat = 8
        let distanceInsets = LayoutInsets(left: 15, right: 15)

        let priceFont = UIFont.wrfFont(ofSize: 13)
        let priceTextColor = UIColor.white.withAlphaComponent(0.8)
        let priceInsets = LayoutInsets(top: 5, bottom: 15, right: 15)
        let priceLineHeight: CGFloat = 15

        let ratingStarFilledColor = Palette.shared.white
        let ratingStarClearColor = Palette.shared.white.withAlphaComponent(0.5)
        let ratingStarsSpacing: CGFloat = 4
        let ratingStarsSize = CGSize(width: 15, height: 15)

        let ratingFont = UIFont.wrfFont(ofSize: 13)
        let ratingTextColor = UIColor.white.withAlphaComponent(0.8)
        let ratingLineHeight: CGFloat = 15

        let ratingInsets = LayoutInsets(top: 5, left: 15, bottom: 15)
        let ratingStarsLabelSpacing: CGFloat = 9

        let addressFont = UIFont.wrfFont(ofSize: 13)
        let addressTextColor = UIColor.white.withAlphaComponent(0.8)
        let addressInsets = LayoutInsets(top: 0, left: 15, right: 15)
        let addressLineHeight: CGFloat = 15

        let logoInsets = LayoutInsets(top: 8, left: 12, bottom: 8)
        let logoWidth = 64.0
        let logoHeight = 45.0
    }
}

final class RestaurantHeaderView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var overlayGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        ]
        layer.locations = [0, 0.48, 1]
        layer.startPoint = CGPoint(x: 0.35, y: 0.5)
        layer.endPoint = CGPoint(x: 0.65, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        )
        return layer
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameFont
        label.textColor = self.appearance.nameTextColor
        return label
    }()

    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.addressFont
        label.textColor = self.appearance.addressTextColor
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
            starsImage: #imageLiteral(resourceName: "restaurant-item-star-rating")
        )
        let view = StarsRatingView(appearance: appearance)
        view.starsCount = 0
        return view
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

    var ratingText: String? {
        didSet {
            self.ratingLabel.attributedText = LineHeightStringMaker.makeString(
                self.ratingText ?? "",
                editorLineHeight: self.appearance.ratingLineHeight,
                font: self.appearance.ratingFont
            )
        }
    }

    var isRatingHidden = false {
        didSet {
            self.ratingStackView.isHidden = self.isRatingHidden

            self.addressLabel.snp.remakeConstraints { make in
                make.leading.equalToSuperview().offset(self.appearance.addressInsets.left)
                make.trailing
                    .lessThanOrEqualTo(self.distanceStackView.snp.leading)
                    .offset(-self.appearance.addressInsets.right)

                if self.isRatingHidden {
                    make.bottom.equalToSuperview().offset(-self.appearance.ratingInsets.bottom)
                } else {
                    make.bottom.equalTo(self.ratingStackView.snp.top).offset(-self.appearance.ratingInsets.top)
                }
            }
        }
    }

    var rating = 0 {
        didSet {
            self.ratingView.starsCount = self.rating
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

    var logoURL: URL? {
        didSet {
            guard let logoURL else { return }
            Nuke.loadImage(with: logoURL, into: logoImageView)
        }
    }

    var address: String? {
        didSet {
            self.addressLabel.attributedText = LineHeightStringMaker.makeString(
                self.address ?? "",
                editorLineHeight: self.appearance.addressLineHeight,
                font: self.appearance.addressFont
            )
        }
    }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.resetOverlayPosition()
    }

    // MARK: - Public API

    func clear() {
        self.nameLabel.attributedText = nil
        self.addressLabel.attributedText = nil
        self.imageView.image = nil
    }

    // MARK: - Private API

    func resetOverlayPosition() {
        self.overlayGradientLayer.bounds = self.imageView.bounds.insetBy(
            dx: -0.5 * self.imageView.bounds.size.width,
            dy: -self.imageView.bounds.size.height
        )
        self.overlayGradientLayer.position = self.imageView.center
    }
}

extension RestaurantHeaderView: ProgrammaticallyDesignable {
    func setupView() {
        logoImageView.isHidden = !PGCMain.shared.featureFlags.map.showRestaurantLogo
        priceLabel.isHidden = !PGCMain.shared.featureFlags.restaurants.shouldShowPrice
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.imageView.layer.addSublayer(self.overlayGradientLayer)
        addSubview(logoImageView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.addressLabel)
        self.addSubview(self.distanceStackView)
        self.addSubview(self.priceLabel)
        self.addSubview(self.ratingStackView)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.logoInsets.left)
            make.top.equalToSuperview().offset(self.appearance.logoInsets.top)
            make.width.equalTo(appearance.logoWidth)
            make.height.equalTo(appearance.logoHeight)
        }

        self.ratingStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.ratingInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.ratingInsets.bottom)
        }

        self.addressLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.addressInsets.left)
            make.bottom.equalTo(self.ratingStackView.snp.top).offset(-self.appearance.ratingInsets.top)
            make.trailing
                .lessThanOrEqualTo(self.distanceStackView.snp.leading)
                .offset(-self.appearance.addressInsets.right)
        }

        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.nameInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.nameInsets.right)
            make.bottom.equalTo(self.addressLabel.snp.top).offset(-self.appearance.addressInsets.top)
        }

        self.priceLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-self.appearance.priceInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.priceInsets.right)
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.addressInsets.right)
        }

        self.distanceStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.distanceInsets.right)
            if PGCMain.shared.featureFlags.map.showRestaurantLogo {
                make.top.equalTo(logoImageView.snp.top)
            } else {
                make.bottom.equalTo(self.priceLabel.snp.top).offset(-self.appearance.priceInsets.top)
            }
        }
        self.distanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.distanceIconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.distanceStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
