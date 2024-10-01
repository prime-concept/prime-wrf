import SnapKit
import TagListView
import UIKit

extension RestaurantDeliveryButtonView {
    struct Appearance {
        let insets = LayoutInsets(top: 5, left: 15, bottom: 0, right: 15)

        let deliveryButtonFont = UIFont.wrfFont(ofSize: 14)
        let deliveryButtonEditorLineHeight: CGFloat = 16
        let deliveryButtonHeight: CGFloat = 40
    }
}

final class RestaurantDeliveryButtonView: UIView {
    let appearance: Appearance

    private lazy var deliveryButton: UIControl = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.deliveryButtonFont
        appearance.mainEditorLineHeight = self.appearance.deliveryButtonEditorLineHeight
        let button = ShadowButton(appearance: appearance)
        button.title = "Заказать доставку"
        button.addTarget(self, action: #selector(self.deliveryButtonClicked), for: .touchUpInside)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.deliveryButtonHeight + self.appearance.insets.top + self.appearance.insets.bottom
        )
    }

    var onButtonClick: (() -> Void)?

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

    @objc
    private func deliveryButtonClicked() {
        self.onButtonClick?()
    }
}

extension RestaurantDeliveryButtonView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.deliveryButton)
    }

    func makeConstraints() {
        self.deliveryButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            make.height.equalTo(self.appearance.deliveryButtonHeight)
        }
    }
}
