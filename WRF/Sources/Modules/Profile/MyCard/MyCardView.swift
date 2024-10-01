import UIKit

protocol MyCardViewDelegate: AnyObject {
    func myCardViewDidSelectCard(_ view: MyCardView)
    func myCardViewDidRequestQRRefresh(_ view: MyCardView)
    func myCardViewDidRequestQRScan(_ view: MyCardView)
	
	func myCardViewDidSelectCertificates(_ view: MyCardView)
}

extension MyCardView {
    struct Appearance {
        let itemHeight: CGFloat = 220
        let itemOffset = LayoutInsets(top: 15, left: 15, bottom: 15, right: 15)

        let qrScanViewInsets = LayoutInsets(left: 15, bottom: 15, right: 15)
        let qrScanViewHeight: CGFloat = 40
        let qrScanViewCornerRadius: CGFloat = 8

        let contentInsetTop: CGFloat = 24
    }
}

final class MyCardView: UIView {
    let appearance: Appearance

    weak var delegate: MyCardViewDelegate?

    var fullName: String? {
        didSet {
            self.cardView.fullName = self.fullName
        }
    }

    var gradeName: String? {
        didSet {
            self.cardView.gradeName = self.gradeName
        }
    }

    var balance: String? {
        didSet {
            self.cardView.balance = self.balance
        }
    }

    var userImage: UIImage? {
        didSet {
            self.cardView.userImage = self.userImage
        }
    }

    var qrImage: UIImage? {
        didSet {
            self.cardView.qrImage = self.qrImage
        }
    }

    var cardNumber: String? {
        didSet {
            self.cardView.cardNumber = self.cardNumber
        }
    }

    var isMyCardLoading = true {
        didSet {
            self.cardView.isMyCardLoading = self.isMyCardLoading
        }
    }

    var isQRCodeLoading = false {
        didSet {
            self.cardView.isQRCodeLoading = self.isQRCodeLoading
        }
    }

    var isQRCodeRetry = false {
        didSet {
            self.cardView.isQRCodeRetry = self.isQRCodeRetry
        }
    }

    private(set) lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.alwaysBounceVertical = true
        scroll.contentInset.top = appearance.contentInsetTop
        return scroll
    }()

    // Strange hacky view, should be removed
    private lazy var stubView = UIView()

    private(set) lazy var cardView: CardView = {
        let view = CardView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cardClicked))
        view.addGestureRecognizer(tapGesture)
        view.onRefreshButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.myCardViewDidRequestQRRefresh(strongSelf)
        }
        return view
    }()

    private lazy var qrScanView: UIView = {
        let view = QRScanView()
        view.onQRTap = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.myCardViewDidRequestQRScan(strongSelf)
        }
        return view
    }()

    // Hidden now, see WRF-94
    private lazy var discountView = DiscountView()

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

    // MARK: - Private api

    @objc
    private func cardClicked() {
        self.delegate?.myCardViewDidSelectCard(self)
    }
}

extension MyCardView: ProgrammaticallyDesignable {
    func setupView() {
        self.qrScanView.isHidden = PGCMain.shared.featureFlags.profile.scanButtonHidden
        self.qrScanView.clipsToBounds = true
        self.qrScanView.layer.cornerRadius = self.appearance.qrScanViewCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stubView)
        self.scrollView.addSubview(self.cardView)
        self.addSubview(self.qrScanView)
    }

    func makeConstraints() {
        self.scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }

        self.stubView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }

        self.cardView.translatesAutoresizingMaskIntoConstraints = false
        self.cardView.snp.makeConstraints { make in
            make.top.equalTo(self.stubView.snp.bottom)
            make.leading.equalToSuperview().offset(self.appearance.itemOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.itemOffset.right)
            make.height.equalTo(self.appearance.itemHeight)
        }

        self.qrScanView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-self.appearance.qrScanViewInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.qrScanViewInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.qrScanViewInsets.right)
            make.height.equalTo(self.appearance.qrScanViewHeight)
        }
    }
}
