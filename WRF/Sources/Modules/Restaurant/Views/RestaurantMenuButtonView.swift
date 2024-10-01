import SnapKit
import TagListView
import UIKit

extension RestaurantMenuButtonView {
    struct Appearance {
        let insets = LayoutInsets(top: 20, left: 15, bottom: 0, right: 15)

        let menuButtonFont = UIFont.wrfFont(ofSize: 14)
        let menuButtonEditorLineHeight: CGFloat = 16
        let menuButtonHeight: CGFloat = 40
    }
}

final class RestaurantMenuButtonView: UIView {
    let appearance: Appearance

    private lazy var menuButton: UIControl = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.menuButtonFont
        appearance.mainEditorLineHeight = self.appearance.menuButtonEditorLineHeight
        let button = ShadowButton(appearance: appearance)
        button.title = "Меню"
        button.addTarget(self, action: #selector(self.menuButtonClicked), for: .touchUpInside)
        return button
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.menuButtonHeight + self.appearance.insets.top + self.appearance.insets.bottom
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
    private func menuButtonClicked() {
        self.onButtonClick?()
    }
}

extension RestaurantMenuButtonView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.menuButton)
    }

    func makeConstraints() {
        self.menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            make.height.equalTo(self.appearance.menuButtonHeight)
        }
    }
}
