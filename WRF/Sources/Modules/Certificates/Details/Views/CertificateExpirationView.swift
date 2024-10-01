import UIKit

final class CertificateExpirationView: UIView {
	struct Appearance {
		let titleColor = UIColor(red: 1, green: 0.249, blue: 0.249, alpha: 1)
		let titleFont = UIFont.wrfFont(ofSize: 16)

		let codeColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
		let codeFont = UIFont.wrfFont(ofSize: 30, weight: .medium)
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

	private let appearance: Appearance = ApplicationAppearance.appearance()

	init() {
		super.init(frame: .zero)

		self.setupSubviews()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setup(with viewModel: CertificateDetailsViewModel.Expiration) {
		self.titleLabel.text = viewModel.title
		self.codeLabel.text = viewModel.code
	}

	private func setupSubviews() {
		let vStack = UIStackView.vertical(
			self.titleLabel,
			self.codeLabel
		)
		vStack.spacing = 20

		self.addSubview(vStack)

		vStack.make(.edges, .equalToSuperview, [20, 15, -10, -15])
	}
}
