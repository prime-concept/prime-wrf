import UIKit
import Nuke

final class CertificateDetailsHeaderView: UIView {
	struct Appearance {
		let imageCornerRadius: CGFloat = 4
        var imageTintColor = Palette.shared.iconsPrimary

		let titleFont = UIFont.wrfFont(ofSize: 20, weight: .medium)
        let titleColor = Palette.shared.textPrimary

		let descriptionFont = UIFont.wrfFont(ofSize: 13)
		let descriptionColor = Palette.shared.textPrimary
		let descriptionLineHeight: CGFloat = 15

        let separatorColor = Palette.shared.strokeStrong
        var backgroundColor = Palette.shared.backgroundColor0
	}

	private lazy var iconImageView = UIImageView { (imageView: UIImageView) in
		imageView.make(.size, .equal, [24, 24])
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = self.appearance.imageCornerRadius
		imageView.image = UIImage(named: "certificate-empty-big")
        imageView.tintColorThemed = appearance.imageTintColor
	}

    private lazy var titleLabel = with(UILabel()) { label in
		label.textColorThemed = self.appearance.titleColor
		label.font = self.appearance.titleFont
    }

    private lazy var descriptionLabel = with(UILabel()) { label in
		label.textColorThemed = self.appearance.descriptionColor
		label.font = self.appearance.descriptionFont
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
    }

    private lazy var separatorView = with(UIView()) { view in
		view.backgroundColorThemed = self.appearance.separatorColor
		view.make(.height, .equal, 1)
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

	func update(with viewModel: CertificateDetailsViewModel.Header) {
		self.titleLabel.text = viewModel.title
		if let url = viewModel.iconURL {
			Nuke.loadImage(with: url, into: self.iconImageView)
		}

		self.descriptionLabel.attributedText = viewModel.description.attributed()
			.alignment(.center)
			.font(self.appearance.descriptionFont)
			.foregroundColor(self.appearance.descriptionColor)
			.lineHeight(self.appearance.descriptionLineHeight)
			.lineBreakMode(.byWordWrapping)
			.string()
	}

    private func setupSubviews() {
        self.backgroundColorThemed = self.appearance.backgroundColor
		let titleStackView = UIStackView.horizontal(
			.hSpacer(growable: 0),
			self.iconImageView,
			self.titleLabel,
			.hSpacer(growable: 0)
		)

		titleStackView.spacing = 10

		with(titleStackView.arrangedSubviews) { views in
			views.first!.make(.width, .equal, to: views.last!)
		}

		self.addSubview(titleStackView)
		titleStackView.make(.top, .equalToSuperview)
		titleStackView.make(.hEdges, .equalToSuperview, [15, -15])

		self.addSubview(self.descriptionLabel)
		self.descriptionLabel.make(.top, .equal, to: .bottom, of: titleStackView, +20)
		self.descriptionLabel.make(.hEdges, .equalToSuperview, [15, -15])

		self.addSubview(self.separatorView)
		self.separatorView.make(.top, .equal, to: .bottom, of: self.descriptionLabel, +20)
		self.separatorView.make([.leading, .trailing, .bottom], .equalToSuperview)
    }
}
