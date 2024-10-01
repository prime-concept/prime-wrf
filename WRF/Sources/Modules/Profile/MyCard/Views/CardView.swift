import SnapKit
import UIKit

extension CardView {
    struct Appearance: Codable {
        var qrCodeImageViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 20)
        var userViewInsets = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)

        var rectangleGradientColor = Palette.shared.white
        var overlayGradientColors = [
            Palette.shared.cardGradient0,
            Palette.shared.cardGradient1
        ]

        var cardHeaderHeight: CGFloat = 64
        var userViewHeight: CGFloat = 50
        var cornerRadius: CGFloat = 15
        
        var backgroundColor = Palette.shared.backgroundColor1
        var loadingViewBackgroundColor = Palette.shared.backgroundColor1
    }
}

final class CardView: UIView {
    let appearance: Appearance

    var fullName: String? {
        didSet {
            self.userView.fullName = self.fullName
        }
    }

    var gradeName: String? {
        didSet {
            self.userView.gradeName = self.gradeName
        }
    }

    var balance: String? {
        didSet {
            self.cardHeaderView.balance = self.balance
        }
    }

    var userImage: UIImage? {
        didSet {
            self.userView.userImage = self.userImage
        }
    }

    var qrImage: UIImage? {
        didSet {
            self.qrCodeView.qrImage = self.qrImage
        }
    }

    var cardNumber: String? {
        didSet {
            guard let cardNumber = self.cardNumber else {
                return
            }
            self.qrCodeView.cardNumber = cardNumber
        }
    }

    var isMyCardLoading: Bool = true {
        didSet {
            self.loadingView.isHidden = !self.isMyCardLoading
        }
    }

    var isQRCodeLoading: Bool {
        get {
            return self.qrCodeView.isQRCodeLoading
        }
        set {
            self.qrCodeView.isQRCodeLoading = newValue
        }
    }

    var isQRCodeRetry: Bool {
        get {
            return self.qrCodeView.isQRCodeRetry
        }
        set {
            self.qrCodeView.isQRCodeRetry = newValue
        }
    }

    var onRefreshButtonClick: (() -> Void)? {
        get {
            return self.qrCodeView.onRefreshButtonClick
        }
        set {
            self.qrCodeView.onRefreshButtonClick = newValue
        }
    }

    private lazy var overlayGradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colorsThemed = self.appearance.overlayGradientColors
        gradient.locations = [0, 1]
        gradient.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradient.transform = CATransform3DMakeAffineTransform(
            CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0)
        )
        return gradient
    }()

    private lazy var glossView: UIView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.image = UIImage(named: "card-triangle-gloss")
        return view
    }()

    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.loadingViewBackgroundColor
        return view
    }()

    private lazy var loadingIndicatorView = WineLoaderView()

    private lazy var qrCodeView = MyCardQRCodeView()

    private lazy var cardBackgroundImageView = UIImageView(image: UIImage(named: "mycard-background"))

    private lazy var cardHeaderView = CardHeaderView()

    private lazy var userView = UserView()

    init(frame: CGRect = .zero, appearance: Appearance = Theme.shared.cardViewAppearance) {
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

    // MARK: - Private api

    private func resetOverlayPosition() {
        self.overlayGradientLayer.bounds = self.bounds.insetBy(
            dx: -0.5 * self.bounds.size.width,
            dy: -self.bounds.size.height
        )
        self.overlayGradientLayer.position = self.center
    }
}

extension CardView: ProgrammaticallyDesignable {
    func setupView() {
        backgroundColorThemed = appearance.backgroundColor

        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.addSublayer(self.overlayGradientLayer)

        self.loadingIndicatorView.startAnimating()
    }

    func addSubviews() {
        self.addSubview(self.glossView)
        if PGCMain.shared.featureFlags.loyalty.showsPersonifiedFeatures {
            self.addSubview(self.qrCodeView)
        }
        if PGCMain.shared.featureFlags.loyalty.shouldUseCardImage {
            self.addSubview(self.cardBackgroundImageView)
        }
        self.addSubview(self.cardHeaderView)
        self.addSubview(self.userView)
        self.addSubview(self.loadingView)
        self.loadingView.addSubview(self.loadingIndicatorView)
    }

    func makeConstraints() {
        self.glossView.translatesAutoresizingMaskIntoConstraints = false
        self.glossView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        if PGCMain.shared.featureFlags.loyalty.shouldUseCardImage {
            self.cardBackgroundImageView.snp.makeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.6)
            }
        }
        self.cardHeaderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(appearance.cardHeaderHeight)
        }

        if PGCMain.shared.featureFlags.loyalty.showsPersonifiedFeatures {
            self.qrCodeView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-self.appearance.qrCodeImageViewInsets.right)
                make.bottom.equalToSuperview().offset(-self.appearance.qrCodeImageViewInsets.bottom)
            }
        }

        self.userView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.userViewInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.userViewInsets.bottom)
            make.height.equalTo(self.appearance.userViewHeight)
            if PGCMain.shared.featureFlags.loyalty.showsPersonifiedFeatures {
                make.trailing
                    .equalTo(self.qrCodeView.snp.leading)
                    .offset(-self.appearance.userViewInsets.right)
            } else {
                make.trailing
                    .equalTo(self.snp.trailing)
                    .offset(-self.appearance.userViewInsets.right)
            }
        }

        self.loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.loadingIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
