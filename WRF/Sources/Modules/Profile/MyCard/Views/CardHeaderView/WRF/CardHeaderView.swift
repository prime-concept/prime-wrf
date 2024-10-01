import UIKit

// WRF

extension CardHeaderView {
    struct Appearance: Codable {
        var pointsLabelColor = Palette.shared.textPrimary
        var pointsLabelEditorLineHeight: CGFloat = 23
        var pointsLabelInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 20)

        var discountLabelColor = Palette.shared.textPrimary
        var discountLabelEditorLineHeight: CGFloat = 23

        var pointsViewColor = Palette.shared.iconsPrimary

        var logoInsets = UIEdgeInsets(top: 20, left: 15, bottom: 0, right: 0)
        var logoWidth: CGFloat = 88
    }
}

final class CardHeaderView: UIView {
    let appearance: Appearance

    var balance: String? {
        didSet {
			self.pointsView.isHidden = false
            self.pointsLabel.attributedText = LineHeightStringMaker.makeString(
				balance ?? "0 баллов",
                editorLineHeight: self.appearance.pointsLabelEditorLineHeight,
                font: UIFont.wrfFont(ofSize: 21)
            )
			self.pointsLabel.adjustsFontSizeToFitWidth = true
        }
    }

	private lazy var pointsView: UIView = with(UIStackView()) { (stack: UIStackView) in
		stack.axis = .horizontal
		stack.spacing = 6
		stack.alignment = .center

        let renderingMode: UIImage.RenderingMode = PGCMain.shared.featureFlags.appSetup.isMaisonDellosTarget
            ? .alwaysTemplate
            : .alwaysOriginal
        var image: UIImage? = UIImage(named: "certificate-currency")?.withRenderingMode(renderingMode)
        let imageView = UIImageView(image: image)
        imageView.tintColorThemed = appearance.pointsViewColor
        imageView.make(.size, .equal, [17, 17])
		stack.addArrangedSubviews(self.pointsLabel, UIStackView.vertical(.vSpacer(3), imageView))

		stack.isHidden = true
	}

    private lazy var pointsLabel: UILabel = {
        let label = UILabel()
        label.textColorThemed = self.appearance.pointsLabelColor
        label.font = UIFont.wrfFont(ofSize: 21)
        return label
    }()

    private lazy var logoImageView = UIImageView(image: UIImage(named: "dark-logo"))

    init(frame: CGRect = .zero, appearance: Appearance = Theme.shared.cardHeaderViewAppearance) {
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
}

extension CardHeaderView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.logoImageView)
		self.addSubview(self.pointsView)
    }

    func makeConstraints() {
        self.logoImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.logoInsets.left)
            make.width.equalTo(appearance.logoWidth)
        }

		self.pointsView.make(.centerY, .equal, to: self.logoImageView)
		self.pointsView.make(.trailing, .equalToSuperview, -self.appearance.pointsLabelInsets.right)
    }
}
