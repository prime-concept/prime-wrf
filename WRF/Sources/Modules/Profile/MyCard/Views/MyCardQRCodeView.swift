import UIKit

extension MyCardQRCodeView {
    struct Appearance: Codable {
        var cardNumberTextColor = Palette.shared.textPrimary
        var cardNumberEditorLineHeight: CGFloat = 14

        var qrImageSize = CGSize(width: 100, height: 100)
        var spacing: CGFloat = 5

        var qrTintColor = Palette.shared.backgroundColorInverse1

        var overlayRoundViewSize = CGSize(width: 52, height: 52)
        var overlayRoundViewLoadingColor = Palette.shared.white
        var overlayRoundViewRetryColor = Palette.shared.black

        var qrCodeAlphaDisabled: CGFloat = 0.1
        var refreshButtonTintColor = Palette.shared.white
    }
}

final class MyCardQRCodeView: UIView {
    let appearance: Appearance

    var qrImage: UIImage? {
        didSet {
            self.qrCodeImageView.image = self.qrImage
            self.qrCodeImageView.tintColorThemed = self.appearance.qrTintColor
        }
    }

    var cardNumber: String? {
        didSet {
            self.cardNumberLabel.attributedText = LineHeightStringMaker.makeString(
                self.cardNumber ?? "",
                editorLineHeight: self.appearance.cardNumberEditorLineHeight,
                font: UIFont.wrfFont(ofSize: 12, weight: .medium),
                alignment: .center
            )
        }
    }

    var isQRCodeLoading = false {
        didSet {
            if self.isQRCodeLoading {
                self.qrCodeImageView.alpha = self.appearance.qrCodeAlphaDisabled
                self.refreshOverlayView.backgroundColorThemed = self.appearance.overlayRoundViewLoadingColor
                self.loadingIndicator.startAnimating()
                self.refreshOverlayView.isHidden = false
                self.refreshButton.isHidden = true
            } else {
                self.qrCodeImageView.alpha = 1.0
                self.refreshOverlayView.isHidden = true
                self.loadingIndicator.stopAnimating()
            }
        }
    }

    var isQRCodeRetry = false {
        didSet {
            if self.isQRCodeRetry {
                self.qrCodeImageView.alpha = self.appearance.qrCodeAlphaDisabled
                self.refreshOverlayView.backgroundColorThemed = self.appearance.overlayRoundViewRetryColor
                self.refreshOverlayView.isHidden = false
                self.refreshButton.isHidden = false
            } else {
                self.qrCodeImageView.alpha = 1.0
                self.refreshOverlayView.isHidden = true
            }
        }
    }

    var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    var onRefreshButtonClick: (() -> Void)?

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        let height = self.appearance.qrImageSize.height
            + self.appearance.spacing
            + self.cardNumberLabel.intrinsicContentSize.height
        return CGSize(width: size.width, height: height)
    }

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.qrCodeImageView, self.cardNumberLabel])
        stack.axis = .vertical
        stack.spacing = self.appearance.spacing
        return stack
    }()

    private lazy var refreshOverlayView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.cornerRadius = self.appearance.overlayRoundViewSize.width / 2
        return view
    }()

    private lazy var qrCodeImageView: UIImageView = {
        let image = UIImageView()
        image.tintColorThemed = self.appearance.qrTintColor
        return image
    }()

    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColorThemed = self.appearance.refreshButtonTintColor
        button.addTarget(self, action: #selector(self.refreshButtonClicked), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "qr-refresh"), for: .normal)
        return button
    }()

    private lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.wrfFont(ofSize: 12, weight: .medium)
        label.textColorThemed = self.appearance.cardNumberTextColor
        return label
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Theme.shared.myCardQRCodeViewAppearance) {
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

    // MARK: - Private

    @objc
    private func refreshButtonClicked() {
        self.onRefreshButtonClick?()
    }
}

extension MyCardQRCodeView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.refreshOverlayView)
        self.refreshOverlayView.addSubview(self.loadingIndicator)
        self.refreshOverlayView.addSubview(self.refreshButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.qrCodeImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.qrImageSize)
        }

        self.refreshOverlayView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.overlayRoundViewSize)
            make.center.equalTo(self.qrCodeImageView)
        }

        self.loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.refreshButton.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
