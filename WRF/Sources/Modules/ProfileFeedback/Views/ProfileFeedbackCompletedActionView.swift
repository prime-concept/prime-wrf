import SnapKit
import UIKit

extension ProfileFeedbackCompletedActionView {
    struct Appearance {
        let imageSize = CGSize(width: 55, height: 55)

        let backgroundColor = Palette.shared.backgroundColor0

        let titleFont = UIFont.wrfFont(ofSize: 13)
        var titleColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 18
        let titleInsets = LayoutInsets(top: 10, left: 15, right: 15)

        let buttonTitleFont = UIFont.wrfFont(ofSize: 14)
        var buttonTitleTextColor = Palette.shared.textPrimary
        let buttonHeight: CGFloat = 40
        let buttonInsets = LayoutInsets(left: 20, bottom: 15, right: 15)
    }
}

final class ProfileFeedbackCompletedActionView: UIView {
    let appearance: Appearance
    let result: Result

    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        return image
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var cancelButton: ShadowButton = {
        var appearance = ShadowButton.Appearance()
        appearance.mainFont = self.appearance.buttonTitleFont
        let button = ShadowButton(appearance: appearance)
        button.title = "Попробовать ещё раз"
        button.addTarget(self, action: #selector(self.cancelButtonClicked), for: .touchUpInside)
        return button
    }()

    var onDismiss: (() -> Void)?

    init(
        frame: CGRect = .zero,
        result: Result,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
        self.appearance = appearance
        self.result = result
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func cancelButtonClicked() {
        self.onDismiss?()
    }

    enum Result {
        case success
        case failure

        var image: UIImage {
            switch self {
            case .success:
                return #imageLiteral(resourceName: "booking-result-success")
            case .failure:
                return #imageLiteral(resourceName: "booking-result-error")
            }
        }

        func makeTitle(appearance: ProfileFeedbackCompletedActionView.Appearance) -> NSAttributedString {
            return LineHeightStringMaker.makeString(
                self == .success
                    ? "Благодарим вас за обратную связь.\nМы ответим в ближайшее время"
                    : "Что-то пошло не так. Проверьте подключение к интернету и попробуйте еще раз",
                editorLineHeight: appearance.titleEditorLineHeight,
                font: appearance.titleFont,
                alignment: .center
            )
        }
    }
}

extension ProfileFeedbackCompletedActionView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = Palette.shared.backgroundColor0
        self.titleLabel.attributedText = self.result.makeTitle(appearance: self.appearance)
        self.imageView.image = self.result.image
        self.cancelButton.isHidden = self.result == .success
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.cancelButton)
    }

    func makeConstraints() {
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(self.appearance.imageSize)
            make.bottom.equalTo(self.titleLabel.snp.top).offset(-self.appearance.titleInsets.top)
        }

        self.cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-self.appearance.buttonInsets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.buttonInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.buttonInsets.right)
            make.height.equalTo(self.appearance.buttonHeight)
        }
    }
}
