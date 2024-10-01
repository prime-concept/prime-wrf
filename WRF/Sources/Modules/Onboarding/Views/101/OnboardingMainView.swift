import UIKit

final class OnboardingMainView: UIView {
    struct Appearance {
        let imageInsets = LayoutInsets(top: 12)
        var image = #imageLiteral(resourceName: "onboarding-step-first")
        let descriptionFont = UIFont.wrfFont(ofSize: 14)
        let descriptionTextColor = UIColor.white
        let descriptionNumberOfLines = 3
        let comingSoonSize = CGSize(width: 86, height: 86)
        let descriptionLineHeight = CGFloat(16)
        let descriptionInsets = LayoutInsets(top: 28, left: 18)
        let descriptionAlingment = NSTextAlignment.center
        var descriptionText = "Сообщим вам о статусе вашего заказа,\nнапомним об участии в грядущем\nмероприятии"
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = self.appearance.image
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionFont
        label.numberOfLines = self.appearance.descriptionNumberOfLines
        label.textColor = self.appearance.descriptionTextColor
        label.attributedText = LineHeightStringMaker.makeString(
            self.appearance.descriptionText,
            editorLineHeight: self.appearance.descriptionLineHeight,
            font: self.appearance.descriptionFont,
            alignment: .center
        )
        return label
    }()

    private let appearance: Appearance

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        addSubviews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension OnboardingMainView: ProgrammaticallyDesignable {
    func setupView() {
    }

    func addSubviews() {
        [self.imageView, self.descriptionLabel].forEach(addSubview)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.imageInsets.top)
            make.centerX.equalToSuperview()
        }

        self.imageView.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 749), for: .vertical
        )

        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(
                self.imageView.snp.bottom
            ).offset(self.appearance.descriptionInsets.top)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(self.appearance.descriptionInsets.left)
        }

        self.descriptionLabel.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 750), for: .vertical
        )
    }
}
