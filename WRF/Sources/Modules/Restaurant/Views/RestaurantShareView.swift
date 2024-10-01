import SnapKit
import UIKit

extension RestaurantShareView {
    struct Appearance {
        let buttonEditorLineHeight: CGFloat = 19
        let buttonHeight: CGFloat = 48

        let buttonsSpacing: CGFloat = 5
        let buttonsInsets = LayoutInsets(top: 20, left: 15, bottom: 0, right: 15)

        let giftIconSize = CGSize(width: 20, height: 20)
        let giftIconInsets = LayoutInsets(left: 18, right: 13)

        let shareIconSize = CGSize(width: 16, height: 16)
        let shareIconInsets = LayoutInsets(left: 20, right: 15)
    }
}

final class RestaurantShareView: UIView {
    let appearance: Appearance

    private(set) lazy var giftButton: ShadowIconButton = {
        var appearance = ShadowIconButton.Appearance()
        appearance.leftInset = self.appearance.giftIconInsets.left
        appearance.rightInset = self.appearance.giftIconInsets.right
        appearance.iconSize = self.appearance.giftIconSize
        appearance.mainEditorLineHeight = self.appearance.buttonEditorLineHeight
        let button = ShadowIconButton(appearance: appearance)
        button.iconImage = #imageLiteral(resourceName: "gift-button-icon")
        button.title = "Подари другу"
        return button
    }()

    private(set) lazy var shareButton: ShadowIconButton = {
        var appearance = ShadowIconButton.Appearance()
        appearance.leftInset = self.appearance.shareIconInsets.left
        appearance.rightInset = self.appearance.shareIconInsets.right
        appearance.iconSize = self.appearance.shareIconSize
        appearance.mainEditorLineHeight = self.appearance.buttonEditorLineHeight
        let button = ShadowIconButton(appearance: appearance)
        button.iconImage = #imageLiteral(resourceName: "share-button-icon")
        button.title = "Поделиться"
        return button
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.giftButton, self.shareButton])
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.buttonsSpacing
        stackView.distribution = .fillEqually
        return stackView
    }()

    override var intrinsicContentSize: CGSize {
        let buttonsSize = self.buttonsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.buttonsInsets.top + buttonsSize.height + self.appearance.buttonsInsets.bottom
        )
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
}

extension RestaurantShareView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.buttonsStackView)
    }

    func makeConstraints() {
        self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.buttonsStackView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.buttonHeight)
            make.top.equalToSuperview().offset(self.appearance.buttonsInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.buttonsInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.buttonsInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.buttonsInsets.bottom)
        }
    }
}
