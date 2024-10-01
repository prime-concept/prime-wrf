import UIKit

final class CertificateUsageView: UIView {
	struct Appearance {
		let titleColor = UIColor.black
		let titleFont = UIFont.wrfFont(ofSize: 16)

		let codeColor = UIColor.black
		let codeFont = UIFont.wrfFont(ofSize: 30, weight: .medium)

		let expirationColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
		let expirationFont = UIFont.wrfFont(ofSize: 15, weight: .light)
	}

	private lazy var titleLabel = with(UILabel()) { label in
		label.textAlignment = .center
		label.textColor = self.appearance.titleColor
		
		label.font = self.appearance.titleFont

		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
	}

	private lazy var codeLabel = with(UILabel()) { label in
		label.textAlignment = .center
		label.textColor = self.appearance.codeColor
		label.font = self.appearance.codeFont
	}

	private lazy var expirationLabel = with(UILabel()) { label in
		label.textAlignment = .center
		label.textColor = self.appearance.expirationColor
		label.font = self.appearance.expirationFont
	}

	private let appearance: Appearance = ApplicationAppearance.appearance()

	init() {
		super.init(frame: .zero)
		self.setupSubviews()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setup(with viewModel: CertificateDetailsViewModel.Usage) {
		self.titleLabel.text = viewModel.title
		self.codeLabel.text = viewModel.code
		self.expirationLabel.text = viewModel.expiration
	}

	private func setupSubviews() {
		let vStack = UIStackView.vertical(
			self.titleLabel,
			self.codeLabel,
			self.expirationLabel
		)
		vStack.spacing = 20

		self.addSubview(vStack)

		vStack.make(.edges, .equalToSuperview, [20, 15, -15, -10])
	}
}
