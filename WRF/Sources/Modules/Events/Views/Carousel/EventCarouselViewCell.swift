import UIKit
import Nuke
import SnapKit

class EventCarouselViewCell: UICollectionViewCell, Reusable {
	struct Appearance {
		let imageViewCornerRadius: CGFloat = 8
		private(set) lazy var imageViewSize = CGSize(width: 135, height: 190)
        let imageViewBorderColor = Palette.shared.strokeSecondary.withAlphaComponent(0.1)
		let imageViewBorderWidth: CGFloat = 1

		let dateLabelFont = UIFont.wrfFont(ofSize: 12, weight: .regular)
        let dateLabelTextColor = Palette.shared.textPrimary
		let dateLabelEditorLineHeight: CGFloat = 13.79
		let dateLabelInset: CGFloat = 8

		let dateGradientHeight: CGFloat = 50
		private(set) lazy var dateGradientFrame = CGRect(
			origin: CGPoint(x: 0, y: self.imageViewSize.height - self.dateGradientHeight),
			size: CGSize(width: self.imageViewSize.width, height: self.dateGradientHeight)
		)

        let dateGradientStartColor = Palette.shared.black.withAlphaComponent(0)
        let dateGradientEndColor = Palette.shared.black.withAlphaComponent(0.8)

		let titleLabelFont = UIFont.wrfFont(ofSize: 12, weight: .medium)
		let titleLabelTextColor = Palette.shared.textPrimary
		let titleLabelEditorLineHeight: CGFloat = 13.79
		let titleLabelInset: CGFloat = 5

		let titleSubtitleSpacing: CGFloat = 4

		let subtitleLabelFont = UIFont.wrfFont(ofSize: 12, weight: .regular)
		let subtitleLabelTextColor = Palette.shared.textSecondary.withAlphaComponent(0.6) //txt_primary
		let subtitleLabelEditorLineHeight: CGFloat = 13.79

		let selfSize = CGSize(width: 135, height: 239)
	}

	var appearance: Appearance
	var didToggleFavorite: ((Bool) -> Void)?

	convenience override init(frame: CGRect = .zero) {
		self.init(frame: frame, appearance: Appearance())
	}

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

	func update(with viewModel: EventCellViewModel) {
		self.adjustNumberOfLines(with: viewModel)

		self.updateImage(with: viewModel.imageURL)
		self.updateDate(with: viewModel.date)
		self.updateTitle(with: viewModel.title)
		self.updateSubtitle(with: viewModel.subtitle)
		self.isFavorite = viewModel.isFavorite
	}

	private func adjustNumberOfLines(with viewModel: EventCellViewModel) {
		self.titleLabel.numberOfLines = 2
		self.subtitleLabel.numberOfLines = 1

		if viewModel.title?.isEmpty ?? true {
			self.subtitleLabel.numberOfLines = 3
		}
		if viewModel.subtitle?.isEmpty ?? true {
			self.titleLabel.numberOfLines = 3
		}
	}

	private func updateImage(with url: URL?) {
		guard let url else {
			return
		}
		self.imageView.loadImage(from: url)
	}

	private func updateTitle(with string:  String?) {
		self.titleLabel.attributedText = LineHeightStringMaker.makeString(
			string ?? "",
			editorLineHeight: self.appearance.titleLabelEditorLineHeight,
			font: self.appearance.titleLabelFont
		)

		self.titleLabel.isHidden = self.titleLabel.text?.isEmpty ?? true
	}

	private func updateSubtitle(with string:  String?) {
		guard let subtitle = string else {
			self.subtitleLabel.attributedText = nil
			self.subtitleLabel.isHidden = true
			return
		}
		self.subtitleLabel.attributedText = LineHeightStringMaker.makeString(
			subtitle,
			editorLineHeight: self.appearance.subtitleLabelEditorLineHeight,
			font: self.appearance.subtitleLabelFont
		)

		self.subtitleLabel.isHidden = self.subtitleLabel.text?.isEmpty ?? true
	}

	private func updateDate(with string: String?) {
		guard let date = string else {
			self.dateLabel.attributedText = nil
			self.dateLabel.isHidden = true
			return
		}
		self.dateLabel.attributedText = LineHeightStringMaker.makeString(
			date,
			editorLineHeight: self.appearance.dateLabelEditorLineHeight,
			font: self.appearance.dateLabelFont
		)

		self.dateLabel.isHidden = self.dateLabel.text?.isEmpty ?? true
	}

	private var isFavorite: Bool = false {
		didSet {
			self.favoriteControl.isSelected = self.isFavorite
		}
	}

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.backgroundColor = .lightGray
		imageView.layer.cornerRadius = self.appearance.imageViewCornerRadius
		imageView.layer.borderWidth = self.appearance.imageViewBorderWidth
		imageView.layer.borderColorThemed = self.appearance.imageViewBorderColor
		return imageView
	}()

	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = self.appearance.dateLabelFont
		label.textColorThemed = self.appearance.dateLabelTextColor
		label.textAlignment = .center
		return label
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = self.appearance.titleLabelFont
		label.textColorThemed = self.appearance.titleLabelTextColor
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 2
		return label
	}()

	private(set) lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = self.appearance.subtitleLabelFont
		label.textColorThemed = self.appearance.subtitleLabelTextColor
		label.lineBreakMode = .byTruncatingTail
		label.numberOfLines = 1
		return label
	}()

	private(set) lazy var favoriteControl: FavoriteControl = {
		let favoriteControl = FavoriteControl()
		favoriteControl.addTarget(
			self, 
			action: #selector(self.favoriteClicked),
			for: .touchUpInside
		)
		return favoriteControl
	}()

	private lazy var gradientLayer: CAGradientLayer = {
		let gradient = CAGradientLayer()
		gradient.colorsThemed = [
			self.appearance.dateGradientStartColor,
			self.appearance.dateGradientEndColor
		]
		gradient.frame = self.appearance.dateGradientFrame
		gradient.locations = [0, 1]
		return gradient
	}()

	// MARK: - Public API

	func clear() {
		self.imageView.image = nil
		self.titleLabel.attributedText = nil
		self.isFavorite = false
	}

	// MARK: - Private API
	@objc
	private func favoriteClicked() {
		self.didToggleFavorite?(!self.favoriteControl.isSelected)
	}
}

extension EventCarouselViewCell {
	func setupView() {
		self.imageView.layer.cornerRadius = self.appearance.imageViewCornerRadius
	}

	func addSubviews() {
		self.contentView.addSubview(self.imageView)
		self.contentView.addSubview(self.favoriteControl)

		self.imageView.layer.addSublayer(self.gradientLayer)
		self.imageView.addSubview(self.dateLabel)
	}

	func makeConstraints() {
		self.contentView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		self.imageView.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview()
			make.size.equalTo(self.appearance.imageViewSize)
		}

		self.favoriteControl.snp.makeConstraints { make in
			make.top.trailing.equalToSuperview()
		}

		self.dateLabel.snp.makeConstraints { make in
			make.leading.trailing.bottom.equalToSuperview().inset(self.appearance.dateLabelInset)
		}

		let textStack = UIStackView.vertical(
			self.titleLabel,
			self.subtitleLabel
		)
		textStack.spacing = self.appearance.titleSubtitleSpacing

		self.contentView.addSubview(textStack)
		textStack.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview()
			make.top.equalTo(self.imageView.snp.bottom).offset(self.appearance.titleLabelInset)
		}

		self.contentView.snp.makeConstraints { make in
			make.size.equalTo(self.appearance.selfSize)
				.priority(ConstraintPriority(999))
		}
	}
}
