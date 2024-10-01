import SnapKit
import UIKit

extension RestaurantBookingTimePickerView {
    struct Appearance {
        let timePickerSpacing: CGFloat = 5
        let timePickerButtonSize = CGSize(width: 76, height: 39)
		let timePickerContentInset = UIEdgeInsets.zero

        var loadingColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        var timeSelectedBackgroundColor = Palette.shared.black
        let loadingCornerRadius: CGFloat = 8
    }
}

final class RestaurantBookingTimePickerView: UIView {
    private static let loadingSlotsCount = 10

    let appearance: Appearance

    private lazy var timePickerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset = self.appearance.timePickerContentInset
        scrollView.clipsToBounds = false
        return scrollView
    }()

    private lazy var timePickerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.timePickerSpacing
        return stackView
    }()

    private lazy var loadingPickerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.timePickerSpacing
        return stackView
    }()

    var onUpdate: ((Int) -> Void)?

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

    func configure(with days: [String]) {
        self.timePickerStackView.removeAllArrangedSubviews()

        days.forEach { value in
            var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
            appearance.selectedBackgroundColor = self.appearance.timeSelectedBackgroundColor

            let button = ShadowButton(frame: .zero, appearance: appearance)
            button.title = value
            self.timePickerStackView.addArrangedSubview(button)
            button.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.timePickerButtonSize)
            }
            button.addTarget(self, action: #selector(self.selectTime(_:)), for: .touchUpInside)
        }
    }

    func showLoading() {
        if self.loadingPickerStackView.arrangedSubviews.isEmpty {
            for _ in 0..<RestaurantBookingTimePickerView.loadingSlotsCount {
                let button = UIView()
                button.backgroundColor = self.appearance.loadingColor
                button.layer.cornerRadius = self.appearance.loadingCornerRadius
                self.loadingPickerStackView.addArrangedSubview(button)
                button.snp.makeConstraints { make in
                    make.size.equalTo(self.appearance.timePickerButtonSize)
                }

                // Simple blinking
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.isRemovedOnCompletion = false
                animation.fromValue = 1
                animation.toValue = 0.4
                animation.duration = 0.8
                animation.autoreverses = true
                animation.repeatCount = Float.greatestFiniteMagnitude
                animation.beginTime = CACurrentMediaTime() + 0.5
                button.layer.add(animation, forKey: nil)
            }
        }

        self.timePickerScrollView.isScrollEnabled = false
        self.loadingPickerStackView.isHidden = false
        self.timePickerStackView.isHidden = true
    }

    func hideLoading() {
        self.timePickerScrollView.isScrollEnabled = true
        self.timePickerStackView.isHidden = false
        self.loadingPickerStackView.isHidden = true
    }

    @objc
    private func selectTime(_ sender: UIControl) {
        var selectedIndex = 0
        for (index, button) in self.timePickerStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIControl else {
                continue
            }

            button.isSelected = button === sender
            if button === sender {
                selectedIndex = index
            }
        }
        self.onUpdate?(selectedIndex)
    }
}

extension RestaurantBookingTimePickerView: ProgrammaticallyDesignable {
    func setupView() {
        self.showLoading()
    }

    func addSubviews() {
        self.addSubview(self.timePickerScrollView)
        self.timePickerScrollView.addSubview(self.timePickerStackView)
        self.addSubview(self.loadingPickerStackView)
    }

    func makeConstraints() {
        self.timePickerScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.timePickerScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        self.timePickerStackView.translatesAutoresizingMaskIntoConstraints = false
        self.timePickerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        self.loadingPickerStackView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingPickerStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(self.appearance.timePickerContentInset.left)
            make.height.equalToSuperview()
        }
    }
}
