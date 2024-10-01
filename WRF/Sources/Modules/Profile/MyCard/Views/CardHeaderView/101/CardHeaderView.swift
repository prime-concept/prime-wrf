import UIKit

// 101

extension CardHeaderView {
    struct Appearance {
        let pointsTitleLabelFont = UIFont.wrfFont(ofSize: 9)
        let pointsLabelFont = UIFont.wrfFont(ofSize: 21)
        var pointsLabelColor = ApplicationAppearance.mainColor
        let pointsLabelEditorLineHeight: CGFloat = 23
        let pointsLabelInsets = LayoutInsets(top: 23, right: 20)

        let discountLabelFont = UIFont.wrfFont(ofSize: 21, weight: .bold)
        let discountLabelColor = UIColor.black
        let discountLabelEditorLineHeight: CGFloat = 23

        let logoInsets = LayoutInsets(top: 26, left: 20, bottom: 5)
        var logoSize = CGSize(width: 106, height: 58)
        var logo = #imageLiteral(resourceName: "dark-logo")
    }
}

final class CardHeaderView: UIView {
    let appearance: Appearance

    var balance: Int? {
        didSet {
            self.pointsLabel.attributedText = LineHeightStringMaker.makeString(
                "\(self.balance ?? 0)",
                editorLineHeight: self.appearance.pointsLabelEditorLineHeight,
                font: self.appearance.pointsLabelFont,
                alignment: .right
            )
        }
    }

    private lazy var pointsTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.pointsLabelColor
        label.font = self.appearance.pointsTitleLabelFont
        label.text = "БАЛЛОВ"
        return label
    }()

    private lazy var pointsLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.pointsLabelColor
        label.font = self.appearance.pointsLabelFont
        return label
    }()

    private lazy var logoImageView = UIImageView(image: self.appearance.logo)

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
}

extension CardHeaderView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.logoImageView)
        if FeatureFlags.Loyalty.showsPersonifiedFeatures {
            self.addSubview(self.pointsLabel)
            self.addSubview(pointsTitleLabel)
        }
    }

    func makeConstraints() {
        self.logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.logoInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.logoInsets.left)
            make.size.equalTo(self.appearance.logoSize)
            make.bottom.equalToSuperview().offset(-self.appearance.logoInsets.bottom)
        }

        if FeatureFlags.Loyalty.showsPersonifiedFeatures {
            self.pointsTitleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(self.appearance.logoInsets.top)
                make.right.equalToSuperview().offset(-self.appearance.pointsLabelInsets.right)
            }

            self.pointsLabel.snp.makeConstraints { make in
                make.top.equalTo(self.pointsTitleLabel.snp.bottom)
                make.trailing.equalToSuperview().offset(-self.appearance.pointsLabelInsets.right)
            }
        }
    }
}

