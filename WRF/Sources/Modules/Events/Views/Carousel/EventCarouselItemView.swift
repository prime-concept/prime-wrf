import Nuke
import SnapKit
import UIKit

extension EventCarouselItemView {
	struct Appearance {
		let itemHeight: CGFloat = PGCMain.shared.featureFlags.events.eventCellSize.height

		var cornerRadius: CGFloat = 8

		let titleLabelFont = UIFont.wrfFont(ofSize: 16, weight: .medium)
        let titleLabelTextColor = Palette.shared.textPrimary
		let titleLabelEditorLineHeight: CGFloat = 19.2
		let titleLabelTopOffset: CGFloat = 3

		let subtitleLabelFont = UIFont.wrfFont(ofSize: 14)
        let subtitleLabelTextColor = Palette.shared.textSecondary.withAlphaComponent(0.6)
		let subtitleLabelEditorLineHeight: CGFloat = 16.09

		let dateLabelFont = UIFont.wrfFont(ofSize: 12, weight: .medium)
		let dateLabelTextColor = Palette.shared.textPrimary
		let dateLabelEditorLineHeight: CGFloat = 13.79

		let imageViewSize = CGSize(width: 100, height: 140)
        let imageViewBorderColor = Palette.shared.strokeSecondary.withAlphaComponent(0.1)

		let textContainerSpacing: CGFloat = 4
		let textContainerInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 6)

		let separatorColor = Palette.shared.strokeSecondary.withAlphaComponent(0.1)
	}
}

final class EventCarouselItemView: UIView, EventCellCapable {
	let appearance: Appearance

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

	func update(with viewModel: EventCellViewModel) {
		self.updateImage(with: viewModel.imageURL)
		self.updateDate(with: viewModel.date)
		self.updateTitle(with: viewModel.title)
		self.updateSubtitle(with: viewModel.subtitle)
		self.favoriteControl.isSelected = viewModel.isFavorite
	}

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFill
		imageView.backgroundColor = .lightGray
		imageView.layer.cornerRadius = self.appearance.cornerRadius
		imageView.layer.borderWidth = 1
		imageView.layer.borderColorThemed = self.appearance.imageViewBorderColor
		return imageView
	}()

	private(set) lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.font = self.appearance.subtitleLabelFont
		label.textColorThemed = self.appearance.subtitleLabelTextColor
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		return label
	}()

	private lazy var dateLabel: UILabel = {
		let label = UILabel()
		label.font = self.appearance.dateLabelFont
		label.textColorThemed = self.appearance.dateLabelTextColor
		return label
	}()

	private(set) lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = self.appearance.titleLabelFont
		label.textColorThemed = self.appearance.titleLabelTextColor
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		return label
	}()

    var nearestRestaurant: String? {
        get { nil }
        set { }
    }
    
	let favoriteControl = FavoriteControl()

	private lazy var separator: UIView = {
		let view = UIView()
		view.snp.makeConstraints { make in
			make.height.equalTo(25)
		}

		let line = UIView()
		view.addSubview(line)
		line.backgroundColorThemed = self.appearance.separatorColor

		line.snp.makeConstraints { make in
			let left = self.appearance.imageViewSize.width + self.appearance.textContainerInsets.left
			make.leading.equalToSuperview().inset(left)
			make.trailing.equalToSuperview().offset(15)
			make.top.equalToSuperview().inset(12)
			make.height.equalTo(1)
		}

		return view
	}()

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

	// MARK: - Public API

	func clear() {
		self.imageView.image = nil
		self.titleLabel.attributedText = nil
		self.favoriteControl.isSelected = false
	}

	var itemHeight: CGFloat {
		self.appearance.itemHeight
	}

	func setupView() {
		self.layer.cornerRadius = self.appearance.cornerRadius
	}

	func addSubviews() {
		self.addSubview(self.imageView)
		self.addSubview(self.favoriteControl)
		self.addSubview(self.separator)
	}

	func makeConstraints() {
		self.imageView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(1.5)
			make.bottom.equalTo(self.separator.snp.top).inset(-1.5)
			make.leading.equalToSuperview()
			make.size.equalTo(self.appearance.imageViewSize)
		}

		self.favoriteControl.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(-6)
			make.trailing.equalToSuperview().offset(11)
		}

		let topSpacer = UIView.vSpacer(growable: 0)
		let bottomSpacer = UIView.vSpacer(growable: 0)

		let textContainer = UIStackView.vertical(
			topSpacer,
			self.titleLabel,
			self.subtitleLabel,
			self.dateLabel,
			bottomSpacer
		)

		textContainer.spacing = self.appearance.textContainerSpacing
		topSpacer.snp.makeConstraints { $0.height.equalTo(bottomSpacer) }

		self.addSubview(textContainer)

		textContainer.snp.makeConstraints { make in
			make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.textContainerInsets.left)
			make.top.bottom.equalTo(self.imageView)
			make.trailing.lessThanOrEqualTo(self.favoriteControl.snp.leading).inset(self.appearance.textContainerInsets.right)
		}

		self.separator.snp.makeConstraints { make in
			make.leading.trailing.bottom.equalToSuperview()
		}

		self.favoriteControl.setContentCompressionResistancePriority(.required, for: .horizontal)
		textContainer.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

		self.titleLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
		self.subtitleLabel.setContentCompressionResistancePriority(UILayoutPriority(749), for: .vertical)
		self.dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
	}
}
