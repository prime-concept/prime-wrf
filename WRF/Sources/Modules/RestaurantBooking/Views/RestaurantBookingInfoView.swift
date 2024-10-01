import UIKit

extension RestaurantBookingInfoView {
    struct Appearance {
        let insets = LayoutInsets(top: 0, bottom: 5)
    }
}

final class RestaurantBookingInfoView: UIView {
	private var labelHeightConstraint: NSLayoutConstraint?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .wrfFont(ofSize: 12, weight: .light)
        label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
        label.textColor = .black

		self.labelHeightConstraint = label.make(.height, .equal, 0)
		self.labelHeightConstraint?.isActive = false

        return label
    }()

    private lazy var iconImageView = UIImageView(image: .init(named: "info"))
    private let appearance: Appearance

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

    func setText(_ text: String?) {
		self.titleLabel.attributedText = LineHeightStringMaker.makeString(
			text ?? "",
			editorLineHeight: 18,
			font: .wrfFont(ofSize: 12, weight: .light)
		)

		self.setNeedsLayout()
    }

	override func layoutSubviews() {
		super.layoutSubviews()

		self.layoutTitleLabel()
	}

	private func layoutTitleLabel() {
		let maxSize = CGSize(width: self.titleLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude)
		let maxHeight = self.titleLabel.sizeThatFits(maxSize)

		if let labelHeightConstraint = self.labelHeightConstraint, labelHeightConstraint.constant == maxHeight.height {
			return
		}
		self.labelHeightConstraint?.isActive = true
		self.labelHeightConstraint?.constant = maxHeight.height
	}
}

extension RestaurantBookingInfoView: ProgrammaticallyDesignable {
    func addSubviews() {
        [
            self.titleLabel,
            self.iconImageView
        ].forEach(self.addSubview)
    }

    func makeConstraints() {
        self.iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(self.appearance.insets.top)
        }

        self.titleLabel.snp.makeConstraints { make in
			make.top.equalTo(self.iconImageView)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-15)
			make.bottom.equalToSuperview().inset(self.appearance.insets.bottom)
        }
    }
}
