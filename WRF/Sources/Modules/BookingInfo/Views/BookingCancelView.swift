import Foundation
import UIKit

extension BookingCancelView {
    struct Appearance {
        let buttonColor = UIColor.black
        let cancelButtonFont = UIFont.wrfFont(ofSize: 14, weight: .medium)
        let resetButtonFont = UIFont.wrfFont(ofSize: 14)

        let labelFont = UIFont.wrfFont(ofSize: 16)
        let labelColor = UIColor.black
        let labelEditorLineHeight: CGFloat = 22

        let stackContainerInsets = LayoutInsets(left: 15, bottom: 15, right: 15)
        let stackContainerHeight: CGFloat = 40

        let separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
}

final class BookingCancelView: UIView {
    let appearance: Appearance

    var restaurantName: String? {
        didSet {
            self.cancelLabel.attributedText = LineHeightStringMaker.makeString(
                "Вы действительно хотите\nотменить бронь стола в \(self.restaurantName ?? "")?",
                editorLineHeight: self.appearance.labelEditorLineHeight,
                font: self.appearance.labelFont,
                alignment: .center
            )
        }
    }

    private lazy var cancelLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelColor
        return label
    }()

    private(set) lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(self.appearance.buttonColor, for: .normal)
        button.titleLabel?.font = self.appearance.cancelButtonFont
        button.setTitle("Отменить бронь", for: .normal)
        return button
    }()

    private(set) lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(self.appearance.buttonColor, for: .normal)
        button.titleLabel?.font = self.appearance.resetButtonFont
        button.setTitle("Оставить", for: .normal)
        return button
    }()

    private lazy var cancelStackBackgroundView = ShadowBackgroundView()

    private lazy var cancelStackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                self.cancelButton, self.resetButton
            ]
        )
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
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

    // MARK: - Private API

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.width.equalTo(1 / UIScreen.main.scale)
        }
        return view
    }
}

extension BookingCancelView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
        self.cancelStackBackgroundView.isUserInteractionEnabled = true
    }

    func addSubviews() {
        self.addSubview(self.cancelLabel)
        self.addSubview(self.cancelStackBackgroundView)
        self.cancelStackBackgroundView.addSubview(self.cancelStackView)
    }

    func makeConstraints() {
        self.cancelLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cancelLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.cancelStackBackgroundView.snp.top)
        }

        self.cancelStackBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.cancelStackBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.stackContainerInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.stackContainerInsets.right)
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .offset(-self.appearance.stackContainerInsets.bottom)
            } else {
                make.bottom
                    .equalToSuperview()
                    .offset(-self.appearance.stackContainerInsets.bottom)
            }
            make.height.equalTo(self.appearance.stackContainerHeight)
        }

        let separator = self.makeSeparator()
        self.cancelStackBackgroundView.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        self.cancelStackView.translatesAutoresizingMaskIntoConstraints = false
        self.cancelStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
