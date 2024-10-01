import SnapKit
import UIKit

extension ProfileContactsItemView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let titleColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let titleEditorLineHeight: CGFloat = 14

        let valueFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var valueColor = Palette.shared.textPrimary
        let emailEditorLineHeight: CGFloat = 17

        let stackSpacing: CGFloat = 5
    }
}

final class ProfileContactsItemView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont
            )
        }
    }

    var value: String? {
        didSet {
            self.valueLabel.attributedText = LineHeightStringMaker.makeString(
                self.value ?? "",
                editorLineHeight: self.appearance.emailEditorLineHeight,
                font: self.appearance.valueFont
            )
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleColor
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.valueFont
        label.textColorThemed = self.appearance.valueColor
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.titleLabel, self.valueLabel])
        stack.axis = .vertical
        stack.spacing = self.appearance.stackSpacing
        return stack
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
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
}

extension ProfileContactsItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
