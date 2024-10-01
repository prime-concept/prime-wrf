import SnapKit
import UIKit

extension RestaurantBookingActionView {
    struct Appearance {
        let buttonTitleFont = UIFont.wrfFont(ofSize: 14)
        var buttonTitleTextColor = Palette.shared.textPrimary
        let stackSpacing: CGFloat = 5
    }
}

final class RestaurantBookingActionView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.menuButton,
                self.bookingButton
            ]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = self.appearance.stackSpacing
        return stackView
    }()

    private lazy var menuButton: ShadowButton = {
        var appearance = ShadowButton.Appearance()
        appearance.mainFont = self.appearance.buttonTitleFont
        appearance.mainTextColor = self.appearance.buttonTitleTextColor
        let button = ShadowButton(appearance: appearance)
        button.title = "Меню"
        button.addTarget(self, action: #selector(self.menuButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var bookingButton: ShadowButton = {
        var appearance = ShadowButton.Appearance()
        appearance.mainFont = self.appearance.buttonTitleFont
        appearance.mainTextColor = self.appearance.buttonTitleTextColor
        let button = ShadowButton(appearance: appearance)
        button.title = "Отправить заявку"
        button.tintColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        button.addTarget(self, action: #selector(self.bookingButtonClicked), for: .touchUpInside)
        return button
    }()

    var onBookingButtonClicked: (() -> Void)?
    var onMenuButtonClicked: (() -> Void)?

    var isMenuButtonEnabled = false {
        didSet {
            self.menuButton.isHidden = !self.isMenuButtonEnabled
        }
    }

    var isBookingButtonEnabled = true {
        didSet {
            self.bookingButton.isEnabled = self.isBookingButtonEnabled
            self.bookingButton.alpha = self.isBookingButtonEnabled ? 1.0 : 0.5
        }
    }

    var isBookingWithPhoneEnabled = false {
        didSet {
            let image = self.isBookingWithPhoneEnabled ? UIImage(named: "restaurant-phone") : nil
            self.bookingButton.setImage(image)
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
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

    @objc
    private func bookingButtonClicked() {
        self.onBookingButtonClicked?()
    }

    @objc
    private func menuButtonClicked() {
        self.onMenuButtonClicked?()
    }
}

extension RestaurantBookingActionView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
