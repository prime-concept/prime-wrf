import UIKit

extension DiscountView {
    struct Appearance {
        let discountTextColor = UIColor.white
        let discountTextFont = UIFont.wrfFont(ofSize: 14, weight: .medium)
        let discountEditorLineHeight: CGFloat = 21
        let discountTextInsets = LayoutInsets(top: 10, left: 20, right: 20)

        let cornerRadius: CGFloat = 15

        let imageContainerBorderWidth: CGFloat = 2
        let imageContainerBorderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        let imageContainerSize = CGSize(width: 65, height: 65)
        let imageContainerTopOffset: CGFloat = 25

        let shareButtonHeight: CGFloat = 40
        let shareButtonTopOffset: CGFloat = 10

        let overlayColor = UIColor.black.withAlphaComponent(0.6)
    }
}

final class DiscountView: UIView {
    let appearance: Appearance

    private lazy var backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "discount-background"))

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
    }()

    private lazy var imageContainer: UIView = {
        let view = UIView()
        view.layer.borderWidth = self.appearance.imageContainerBorderWidth
        view.layer.borderColor = self.appearance.imageContainerBorderColor
        return view
    }()

    private lazy var giftImageView = UIImageView(image: #imageLiteral(resourceName: "discount-gift"))

    private lazy var discountTextLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.discountTextFont
        label.numberOfLines = 0
        label.textColor = self.appearance.discountTextColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Подарите другу скидку в 5% в первое посещение ресторана White Rabbit Family",
            editorLineHeight: self.appearance.discountEditorLineHeight,
            font: label.font,
            alignment: .center
        )
        return label
    }()

    private lazy var shareButtonView = ShareButtonView()

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageContainer.layer.cornerRadius = self.imageContainer.frame.width / 2
    }
}

extension DiscountView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.imageContainer)
        self.imageContainer.addSubview(self.giftImageView)
        self.addSubview(self.discountTextLabel)
        self.addSubview(self.shareButtonView)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.imageContainer.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.imageContainerTopOffset)
            make.size.equalTo(self.appearance.imageContainerSize)
            make.centerX.equalToSuperview()
        }

        self.giftImageView.translatesAutoresizingMaskIntoConstraints = false
        self.giftImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.discountTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.discountTextLabel.snp.makeConstraints { make in
            make.top
                .equalTo(self.imageContainer.snp.bottom)
                .offset(self.appearance.discountTextInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.discountTextInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.discountTextInsets.right)
        }

        self.shareButtonView.translatesAutoresizingMaskIntoConstraints = false
        self.shareButtonView.snp.makeConstraints { make in
            make.top
                .equalTo(self.discountTextLabel.snp.bottom)
                .offset(self.appearance.shareButtonTopOffset)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.shareButtonHeight)
        }
    }
}
