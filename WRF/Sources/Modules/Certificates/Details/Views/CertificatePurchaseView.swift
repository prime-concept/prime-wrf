import UIKit

final class CertificatePurchaseView: UIView {
	struct Appearance {
		let costColor = Palette.shared.textPrimary
		let costFont = UIFont.wrfFont(ofSize: 30, weight: .medium)

        let detailColor = Palette.shared.textPrimary
		let detailFont = UIFont.wrfFont(ofSize: 14)

        let expirationColor = Palette.shared.textSecondary
		let expirationFont = UIFont.wrfFont(ofSize: 13, weight: .light)
        var backgroundColor = Palette.shared.backgroundColor0
	}

    private lazy var costLabel = with(UILabel()) { label in
        label.textAlignment = .center
		label.textColorThemed = self.appearance.costColor
		label.font = self.appearance.costFont
    }

    private lazy var detailLabel = with(UILabel()) { label in
        label.textAlignment = .center
		label.textColorThemed = self.appearance.detailColor
		label.font = self.appearance.detailFont
    }

    private lazy var expirationLabel = with(UILabel()) { label in
        label.textAlignment = .center
		label.textColorThemed = self.appearance.expirationColor
        label.font = self.appearance.expirationFont
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
    }

    private lazy var purchaseButton = ShadowButton()

	private let appearance: Appearance = ApplicationAppearance.appearance()

	init() {
		super.init(frame: .zero)

        self.setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	func showLoading() {
		self.purchaseButton.isEnabled = false
		self.purchaseButton.mainLabel.alpha = 0.01

		let loader = UIActivityIndicatorView()
		self.purchaseButton.addSubview(loader)
		loader.make(.center, .equalToSuperview)

		loader.startAnimating()
	}

	func hideLoading() {
		self.purchaseButton.isEnabled = true
		self.purchaseButton.mainLabel.isHidden = false
		self.purchaseButton.mainLabel.alpha = 1

		self.purchaseButton
			.firstSubview(UIActivityIndicatorView.self)?
			.removeFromSuperview()
	}

    func setup(with viewModel: CertificateDetailsViewModel.Purchase) {
        self.costLabel.text = viewModel.price
        self.detailLabel.text = viewModel.purchaseDetails1
        self.expirationLabel.text = viewModel.purchaseDetails2
        self.purchaseButton.title = viewModel.purchaseActionTitle

		self.purchaseButton.setEventHandler(for: .touchUpInside) {
			viewModel.onPurchaseAction()
		}
    }

    private func setupSubviews() {
        self.backgroundColorThemed = self.appearance.backgroundColor
        [
            self.costLabel,
            self.detailLabel,
            self.expirationLabel,
            self.purchaseButton
        ].forEach(self.addSubview)

        self.costLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.detailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.costLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.expirationLabel.snp.makeConstraints { make in
            make.top.equalTo(self.detailLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15)
        }

        self.purchaseButton.snp.makeConstraints { make in
			make.top.equalTo(self.expirationLabel.snp.bottom).offset(40)
			make.bottom.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }

		self.purchaseButton.make(.height, .equal, 40)
		self.purchaseButton.make(.width, .equal, to: self.purchaseButton.mainLabel, +50)
    }
}
