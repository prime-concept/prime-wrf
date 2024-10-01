import UIKit
import Nuke

final class CertificateCell: UITableViewCell {
	let certificateView = CertificateCellContentView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		self.backgroundColor = .clear

		self.contentView.addSubview(self.certificateView)
		self.certificateView.make(.edges, .equalToSuperview, [10, 15, 0, -15])
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

final class CertificateCellContentView: UIView  {
	struct Appearance {
        var backgroundColor = Palette.shared.backgroundColor1
        var cellBackgroundColor = Palette.shared.accentСolor
        var shadowColor = Palette.shared.black
		var shadowOpacity: CGFloat = 0.1

		var titleFont = UIFont.wrfFont(ofSize: 15, weight: .medium)
        var titleColor = Palette.shared.textPrimary

		var descriptionFont = UIFont.wrfFont(ofSize: 12)
        var descriptionColor = Palette.shared.textSecondary

		var priceFont = UIFont.wrfFont(ofSize: 13, weight: .medium)
		var priceColor = Palette.shared.textPrimary

        var imageTintColor = Palette.shared.textPrimary
		var cornerRadius: CGFloat = 10
		var shadowRadius: CGFloat = 4
	}

	private let appearance: Appearance = ApplicationAppearance.appearance()

	private var contentHandler: (() -> Void)?

	private lazy var imageView = UIImageView { (imageView: UIImageView) in
		imageView.make(.size, .equal, [54, 54])
		imageView.contentMode = .scaleAspectFill
		imageView.layer.cornerRadius = self.appearance.cornerRadius
		imageView.layer.masksToBounds = true
		imageView.image = UIImage(named: "certificate-empty-big")
        imageView.tintColorThemed = appearance.imageTintColor
	}

	private var textStack: UIStackView!
	private var textStackLeading: NSLayoutConstraint!

	private lazy var titleLabel = UILabel(
		font: self.appearance.titleFont,
        textColor: self.appearance.titleColor.rawValue
	)

	private lazy var descriptionLabel = UILabel(
		font: self.appearance.descriptionFont,
        textColor: self.appearance.descriptionColor.rawValue,
		numberOfLines: 0
	)

	private lazy var contentView = UIView { view in
		view.backgroundColorThemed = self.appearance.backgroundColor
		view.layer.cornerRadius = self.appearance.cornerRadius - 1 / UIScreen.main.scale

		view.dropShadowThemed(
			offset: CGSize(width: 0, height: 2),
			radius: self.appearance.shadowRadius,
			color: self.appearance.shadowColor,
			opacity: self.appearance.shadowOpacity
		)
	}

	private lazy var priceLabel = UILabel(
		font: self.appearance.priceFont,
        textColor: self.appearance.priceColor.rawValue
	)

	private lazy var priceIconImageView = UIImageView { (imageView: UIImageView) in
		imageView.make(.size, .equal, [13, 13], priorities: [.defaultHigh])
		imageView.contentMode = .scaleAspectFit
	}

	private lazy var priceHStack = UIStackView.horizontal(
		.hSpacer(growable: 0), self.priceLabel, .hSpacer(5), self.priceIconImageView
	)

	private lazy var actionIconImageView = UIImageView { (imageView: UIImageView) in
		imageView.image = UIImage(named: "certificate-currency")
		imageView.contentMode = .scaleAspectFit
	}

	private lazy var actionContainer = UIView()

	init() {
		super.init(frame: .zero)

		self.placeSubviews()

		self.addTapHandler { }
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func placeSubviews() {
		self.backgroundColorThemed = self.appearance.cellBackgroundColor
		self.layer.cornerRadius = self.appearance.cornerRadius

		let contentBackgroundView = UIView { view in
			view.backgroundColorThemed = self.appearance.backgroundColor
			view.layer.cornerRadius = self.appearance.cornerRadius - 1 / UIScreen.main.scale
		}

		self.addSubview(contentBackgroundView)
		contentBackgroundView.make(.edges, .equalToSuperview, [0, 0, 0, -45])

		contentBackgroundView.addSubview(self.contentView)
		self.contentView.make(.edges, .equalToSuperview)

		self.contentView.addSubview(self.imageView)
		self.imageView.make([.centerY, .leading], .equalToSuperview, [1, 10])

		self.titleLabel.make(hug: 999, axis: .horizontal)

		let titleStack = UIStackView.horizontal(self.titleLabel, .hSpacer(5), self.priceHStack)
		titleStack.make(.height, .equal, self.titleLabel.font.lineHeight)

		let textStack = UIStackView.vertical(
			titleStack,
			.vSpacer(7),
			self.descriptionLabel,
			.vSpacer(growable: 0)
		)

		self.contentView.addSubview(textStack)
		self.textStackLeading =
		textStack.make(behind: self.imageView, 15)
		textStack.make(.vEdges, .equalToSuperview, [12, -10])
		textStack.make(.trailing, .equalToSuperview, -10)

		self.textStack = textStack

		self.actionContainer.addSubview(self.actionIconImageView)
		self.actionIconImageView.make(.center, .equalToSuperview)

		self.addSubview(self.actionContainer)
		self.actionContainer.make(.edges(except: .leading), .equalToSuperview)
		self.actionContainer.make(behind: contentBackgroundView)
	}

	func update(with viewModel: SingleCertificateViewModel) {
		if let url = viewModel.iconURL {
			Nuke.loadImage(with: url, into: self.imageView)
		}

		self.titleLabel.text = viewModel.title
		self.descriptionLabel.text = viewModel.description

		self.priceHStack.isHidden = true

		if let price = viewModel.price {
			self.priceHStack.isHidden = false
			self.priceLabel.text = price

			let icon = viewModel.priceIcon ?? UIImage(named: "certificate-currency")
			self.priceIconImageView.image = icon
		}

		self.actionIconImageView.image = viewModel.actionIcon

		_ = self.textStackLeading.remove()

		self.textStack.make(behind: self.imageView, 15)
	}

	private func contentTapped() {
		self.contentHandler?()
	}
}

extension UILabel {
	convenience init(font: UIFont, textColor: UIColor, numberOfLines: Int = 1, text: String? = nil) {
		self.init(frame: .zero)
		self.font = font
		self.textColor = textColor
		self.text = text

		self.numberOfLines = numberOfLines
		if numberOfLines != 1 {
			self.lineBreakMode = .byWordWrapping
		}
	}
}
