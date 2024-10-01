import SnapKit
import UIKit

extension RestaurantBookingStepper {
    struct Appearance {
        let buttonSize = CGSize(width: 40, height: 50)
        var buttonTintColor = UIColor.black

        let mainFont = UIFont.wrfFont(ofSize: 16)
        var mainTextColor = UIColor.black
        let mainEditorLineHeight: CGFloat = 18

        let secondaryFont = UIFont.wrfFont(ofSize: 10, weight: .medium)
        let secondaryTextColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let secondaryEditorLineHeight: CGFloat = 11
        let secondaryLabelInsets = LayoutInsets(top: 2, bottom: 2)

        let elementSpacing: CGFloat = 0
    }
}

final class RestaurantBookingStepper: UIView {
    let appearance: Appearance

    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = self.appearance.buttonTintColor
        button.setImage(#imageLiteral(resourceName: "stepper-plus"), for: .normal)
        button.addTarget(self, action: #selector(self.incrementCounter), for: .touchUpInside)
        return button
    }()

    private lazy var minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = self.appearance.buttonTintColor
        button.setImage(#imageLiteral(resourceName: "stepper-minus"), for: .normal)
        button.addTarget(self, action: #selector(self.decrementCounter), for: .touchUpInside)
        return button
    }()

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.mainFont
        label.attributedText = LineHeightStringMaker.makeString(
            "",
            editorLineHeight: self.appearance.mainEditorLineHeight,
            font: self.appearance.mainFont,
            alignment: .center
        )
        label.textColor = self.appearance.mainTextColor
        return label
    }()

    private lazy var secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.secondaryFont
        label.attributedText = LineHeightStringMaker.makeString(
            "",
            editorLineHeight: self.appearance.secondaryEditorLineHeight,
            font: self.appearance.secondaryFont,
            alignment: .center
        )
        label.textColor = self.appearance.secondaryTextColor
        return label
    }()

    private lazy var dataContainerView = UIView()
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.elementSpacing
        return stackView
    }()

    private(set) var counter = 1 {
        didSet {
            self.onUpdate?(self.counter)
        }
    }

    var onUpdate: ((Int) -> Void)?

    init(frame: CGRect = .zero, counter: Int, appearance: Appearance = ApplicationAppearance.appearance()) {
        self.appearance = appearance
        self.counter = counter
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private API

    @objc
    private func incrementCounter() {
        self.counter += 1
        self.updateSubviews()
    }

    @objc
    private func decrementCounter() {
        self.counter -= 1
        self.updateSubviews()
    }

    private func updateSubviews() {
        self.mainLabel.text = "\(self.counter)"
        self.secondaryLabel.text = Localization.pluralForm(number: self.counter, forms: ["гость", "гостя", "гостей"])
        self.minusButton.isEnabled = self.counter > 1
        self.plusButton.isEnabled = self.counter < 50
    }
}

extension RestaurantBookingStepper: ProgrammaticallyDesignable {
    func setupView() {
        self.updateSubviews()
    }

    func addSubviews() {
        self.dataContainerView.addSubview(self.mainLabel)
        self.dataContainerView.addSubview(self.secondaryLabel)

        self.addSubview(self.containerStackView)
        self.containerStackView.addArrangedSubview(self.minusButton)
        self.containerStackView.addArrangedSubview(self.dataContainerView)
        self.containerStackView.addArrangedSubview(self.plusButton)
    }

    func makeConstraints() {
        self.secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.secondaryLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.secondaryLabelInsets.bottom)
        }

        self.mainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.secondaryLabel.snp.top).offset(-self.appearance.secondaryLabelInsets.top)
        }

        self.containerStackView.translatesAutoresizingMaskIntoConstraints = false
        self.containerStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.plusButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.buttonSize)
        }

        self.minusButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.buttonSize)
        }
    }
}
