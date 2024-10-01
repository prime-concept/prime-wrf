import UIKit
import Nuke

final class CertificatesNavigationView: UIView  {
    struct Appearance: Codable {
        var accentСolor = Palette.shared.accentСolor
        var backgroundColor = Palette.shared.backgroundColor1
        var shadowColor = Palette.shared.black
		var shadowOpacity: CGFloat = 0.1

		var cornerRadius: CGFloat = 10
		var cardCornerRadius: CGFloat = 4
		var shadowRadius: CGFloat = 4

		var certificatesTextColor = Palette.shared.textPrimary
        var countColor = Palette.shared.textSecondary
	}

    private let appearance: Appearance

	private var cardImageViewsContainer = UIView()
	private var cardImageViews = [UIImageView]()
	private var countLabel: UILabel?

	private var tapHandler: (() -> Void)?

	init(frame: CGRect = .zero, appearance: Appearance = Theme.shared.certificatesNavigationViewAppearance) {
        self.appearance = appearance
        super.init(frame: frame)

		self.placeSubviews()

		self.addTapHandler { [weak self] in
			self?.tapHandler?()
		}
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func placeSubviews() {
		self.backgroundColorThemed = self.appearance.accentСolor
		self.layer.cornerRadius = self.appearance.cornerRadius

		let contentView = UIView { view in
			view.backgroundColorThemed = self.appearance.backgroundColor
			view.layer.cornerRadius = self.appearance.cornerRadius - 1 / UIScreen.main.scale

			view.dropShadowThemed(
				offset: CGSize(width: 0, height: 2),
				radius: self.appearance.shadowRadius,
				color: self.appearance.shadowColor,
				opacity: self.appearance.shadowOpacity
			)
		}

		self.addSubview(contentView)
		contentView.make(.edges(except: .trailing), .equalToSuperview)
		contentView.make(.trailing, .equalToSuperview, -45)

		let arrowImageView = UIImageView(image: UIImage(named: "certificate-chevron"))
		self.addSubview(arrowImageView)
		arrowImageView.make(.centerY, .equalToSuperview)
		arrowImageView.make(.trailing, .equalToSuperview, -16, priority: .defaultHigh)

		let cardImageViews = ([0, 1, 2]).map { i in
			UIImageView { (imageView: UIImageView) in
				imageView.image = UIImage(named: "certificate-empty")

				imageView.make(.size, .equal, [46, 28])
				imageView.layer.cornerRadius = self.appearance.cardCornerRadius
				imageView.layer.masksToBounds = true
				imageView.contentMode = .scaleAspectFill
                imageView.tintColorThemed = Palette.shared.iconsPrimary

				self.cardImageViewsContainer.addSubview(imageView)
                imageView.make(.leading, .equalToSuperview, CGFloat(i * 36))
				imageView.make(.height, .equalToSuperview)
				imageView.make(.size, .equal, [46, 28])

				if i > 0 {
					let separator = UIView{
						$0.backgroundColorThemed = self.appearance.backgroundColor
						$0.layer.cornerRadius = 2
						$0.make(.width, .equal, 12)
					}

					imageView.addSubview(separator)
					separator.make(.edges(except: .trailing), .equalToSuperview)
				}
			}
		}

		cardImageViews.forEach { $0.superview?.sendSubviewToBack($0) }
		self.cardImageViews = cardImageViews

		let certificatesLabel = UILabel { (label: UILabel) in
			label.textColorThemed = self.appearance.certificatesTextColor
			label.font = UIFont.wrfFont(ofSize: 14)
			label.text = "Сертификаты"
		}

		let countLabel = UILabel { (label: UILabel) in
			label.textColorThemed = self.appearance.countColor
			label.font = UIFont.wrfFont(ofSize: 14)
		}

		self.countLabel = countLabel

		let labelsStack = UIStackView.horizontal(
			certificatesLabel, .hSpacer(3), countLabel, .hSpacer(growable: 0)
		)

		labelsStack.make(.height, .equal, certificatesLabel.font.lineHeight)

		let stack = UIStackView.vertical(
			cardImageViewsContainer,
			labelsStack
		)

		stack.spacing = 10

		contentView.addSubview(stack)

		stack.make(.hEdges, .equalToSuperview, [13, -13])
		stack.make(.centerY, .equalToSuperview)
	}

	func update(with viewModel: CertificatesNavigationViewModel) {
		self.countLabel?.text = viewModel.count
		self.cardImageViews.forEach {
			$0.isHidden = true
			$0.image = UIImage(named: "certificate-empty")
            $0.tintColorThemed = Palette.shared.iconsPrimary
		}

		viewModel.cardImageURLs.suffix(3).enumerated().forEach { tuple in
			let imageView = self.cardImageViews[tuple.offset]
			imageView.isHidden = false

			Nuke.loadImage(with: tuple.element, into: imageView)
		}

		if viewModel.cardImageURLs.isEmpty {
			self.cardImageViews.first?.isHidden = false
		}
		
		self.tapHandler = viewModel.onTap
	}
}
