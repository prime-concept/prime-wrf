import SnapKit
import UIKit

extension ProfileAboutVersionView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let titleColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let titleEditorLineHeight: CGFloat = 14

        let versionFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var versionColor = Palette.shared.textPrimary
        let versionEditorLineHeight: CGFloat = 17

        let stackSpacing: CGFloat = 5
    }
}

final class ProfileAboutVersionView: UIView {
    let appearance: Appearance

    var version: String? {
        didSet {
            self.versionLabel.attributedText = LineHeightStringMaker.makeString(
                self.version ?? "1.0",
                editorLineHeight: self.appearance.versionEditorLineHeight,
                font: self.appearance.versionFont
            )
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Версия приложения",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        return label
    }()

    private lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.versionFont
        label.textColorThemed = self.appearance.versionColor
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.titleLabel, self.versionLabel])
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

extension ProfileAboutVersionView: ProgrammaticallyDesignable {
    func setupView() { }

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
