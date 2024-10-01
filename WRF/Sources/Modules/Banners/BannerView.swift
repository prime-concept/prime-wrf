import UIKit
import Nuke

final class BannerView: UIView {
	struct Appearance {
        private static let bannerWHRatio = CGFloat(UIApplication.shared.keyWindow?.bounds.width ?? 375) / 375

		let topGradientHeight: CGFloat = ceil(179 * bannerWHRatio)
		let topGradientColors = [
            Palette.shared.backgroundColor0,
            Palette.shared.backgroundColor0.withAlphaComponent(0)
		]

		let bottomGradientHeight: CGFloat = ceil(111 * bannerWHRatio)

		let bottomGradientColors = [
            Palette.shared.backgroundColor0.withAlphaComponent(0),
            Palette.shared.backgroundColor0
		]

		let bookButtonCornerRadius: CGFloat = 8
        let bookButtonBackgroundColor = Palette.shared.backgroundColorInverse1.withAlphaComponent(0.1)

		let bookButtonTitleInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
		let bookButtonTitleTrailing: CGFloat = 16
		let bookButtonTitleFont = UIFont.wrfFont(ofSize: 14, weight: .regular)

        let bookButtonTitleTextColor = Palette.shared.textPrimary
		let bookButtonTitleLineHeight: CGFloat = 16.09
		let bookButtonBottomInset: CGFloat = 47
	}

	let appearance: Appearance

    private var buttonAction: (() -> Void)?

	init(appearance: Appearance = .init()) {
		self.appearance = appearance

		super.init(frame: .zero)

		setupSubviews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupSubviews() {
		clipsToBounds = true

		addSubview(imageView)
		layer.addSublayer(topGradientLayer)
		layer.addSublayer(bottomGradientLayer)
		addSubview(bookingButton)

		bookingButton.snp.makeConstraints { make in
			make.bottom.equalToSuperview().inset(appearance.bookButtonBottomInset)
			make.trailing.equalToSuperview().inset(appearance.bookButtonTitleTrailing)
		}
	}

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		return imageView
	}()

	private lazy var topGradientLayer: CAGradientLayer = {
		let gradient = CAGradientLayer()
        gradient.colorsThemed = appearance.topGradientColors
		gradient.locations = [0, 1]
		return gradient
	}()

	private lazy var bottomGradientLayer: CAGradientLayer = {
		let gradient = CAGradientLayer()
        gradient.colorsThemed = appearance.bottomGradientColors
		gradient.locations = [0, 1]
		return gradient
	}()

	private lazy var bookingTitleLabel: UILabel = {
		let label = UILabel()
        label.textColorThemed = appearance.bookButtonTitleTextColor
		label.font = appearance.bookButtonTitleFont
		return label
	}()

	private lazy var bookingButton: UIView = {
		let view = UIView()
        view.layer.cornerRadius = appearance.bookButtonCornerRadius
        view.backgroundColorThemed = appearance.bookButtonBackgroundColor

        view.addSubview(bookingTitleLabel)
		bookingTitleLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(appearance.bookButtonTitleInsets)
		}

		let button = UIButton()
		button.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)

		view.addSubview(button)
		button.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

        bookingTitleLabel.addTapHandler { [weak self] in
            self?.bookButtonTapped()
        }
        
		return view
	}()

	@objc
	private func bookButtonTapped() {
        buttonAction?()
	}

	func update(with viewModel: BannerViewModel) {
        Nuke.loadImage(
            with: viewModel.imageURL,
            into: imageView,
            completion: { [weak self] _, _ in
            self?.setNeedsLayout()
        })

        bookingTitleLabel.attributedText = LineHeightStringMaker.makeString(
            viewModel.buttonTitle,
            editorLineHeight: appearance.bookButtonTitleLineHeight,
            font: appearance.bookButtonTitleFont
        )

		bookingButton.isHidden = viewModel.buttonTitle.isEmpty
        buttonAction = viewModel.buttonAction
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		layoutImageView()
		layoutGradients()
	}

	private func layoutImageView() {
		var imageViewFrame = bounds
        
        defer { imageView.frame = imageViewFrame }

        guard let image = imageView.image, image.size.width != 0 else {
            return
		}

        let imageViewHWRatio = image.size.height / image.size.width
        imageViewFrame.size.height = imageViewFrame.width * imageViewHWRatio
        imageViewFrame.origin.y = 0
	}

	private func layoutGradients() {
		var topGradientFrame = bounds
		topGradientFrame.size.height = appearance.topGradientHeight
		topGradientLayer.frame = topGradientFrame

		var bottomGradientFrame = bounds
		bottomGradientFrame.size.height = appearance.bottomGradientHeight
		bottomGradientFrame.origin.y = bounds.height - bottomGradientFrame.height
		bottomGradientLayer.frame = bottomGradientFrame
	}
}
