import UIKit

final class CertificateNotificationView: UIView {
	struct Appearance {
		let imageSize: [CGFloat] = [55, 55]

        let textColor = Palette.shared.textPrimary
		let textFont = UIFont.wrfFont(ofSize: 14)

		let expirationColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
		let expirationFont = UIFont.wrfFont(ofSize: 13, weight: .light)
	}

	private lazy var imageView = UIImageView { (imageView: UIImageView) in
		imageView.make(.size, .equal, self.appearance.imageSize, priorities: [999.layoutPriority])
		imageView.contentMode = .scaleAspectFit
	}

	private lazy var textLabel = with(UILabel()) { label in
		label.textAlignment = .center
		label.textColorThemed = self.appearance.textColor
		label.font = self.appearance.textFont

		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
	}

	private lazy var actionButton = ShadowButton()

	private let appearance: Appearance = ApplicationAppearance.appearance()

	init() {
		super.init(frame: .zero)

		self.setupSubviews()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setup(with viewModel: CertificateDetailsViewModel.Notification) {
		self.imageView.image = viewModel.icon
		self.textLabel.attributedText = viewModel.text?.attributed()
			.foregroundColor(self.textLabel.textColor)
			.font(self.textLabel.font)
			.alignment(.center)
			.lineHeight(18)
			.lineBreakMode(.byWordWrapping)
			.string()

		self.actionButton.isHidden = viewModel.actionTitle == nil

		if let actionTitle = viewModel.actionTitle {
			self.actionButton.title = actionTitle
			self.actionButton.setEventHandler(for: .touchUpInside) {
				viewModel.action?()
			}
		}
	}

	func showLoading() {
		self.actionButton.isEnabled = false
		self.actionButton.mainLabel.alpha = 0.01

		let loader = UIActivityIndicatorView()
		self.actionButton.addSubview(loader)
		loader.make(.center, .equalToSuperview)

		loader.startAnimating()
	}

	func hideLoading() {
		self.actionButton.isEnabled = true
		self.actionButton.mainLabel.isHidden = false
		self.actionButton.mainLabel.alpha = 1

		self.actionButton
			.firstSubview(UIActivityIndicatorView.self)?
			.removeFromSuperview()
	}

	private func setupSubviews() {
		let vStack = UIStackView.vertical(
			self.imageView,
			.vSpacer(10),
			self.textLabel,
			.vSpacer(30),
			UIView {
				$0.addSubview(self.actionButton)
				self.actionButton.make([.centerX, .height], .equalToSuperview)
				self.actionButton.make(.height, .equal, 40)
				self.actionButton.make(.width, .equal, to: self.actionButton.mainLabel, +50)
			}
		)

		self.addSubview(vStack)
		vStack.make(.edges, .equalToSuperview, [10, 15, -10, -15])
	}
}
