import SnapKit
import UIKit

extension ProfileAboutServiceView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 17)
        var titleColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 20
        let titleOffset = LayoutInsets(top: 15, left: 15)

        let descriptionFont = UIFont.wrfFont(ofSize: 15)
        var descriptionColor = Palette.shared.textPrimary
        let descriptionEditorLineHeight: CGFloat = 22
        let descriptionOffset = LayoutInsets(top: 20, left: 15, right: 15)

        let versionOffset = LayoutInsets(top: 35, left: 15, bottom: 15)
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileAboutServiceView: UIView {
    let appearance: Appearance

    private lazy var scrollView = UIScrollView()

    private lazy var stubView = UIView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
        label.attributedText = LineHeightStringMaker.makeString(
            "О сервисе",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionFont
        label.textColorThemed = self.appearance.descriptionColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var versionView = ProfileAboutVersionView()

    var version: String? {
        get {
            return self.versionView.version
        }
        set {
            self.versionView.version = newValue
        }
    }

    var text: String {
        get { return self.descriptionLabel.attributedText?.string ?? "" }
        set {
            self.descriptionLabel.attributedText = LineHeightStringMaker.makeString(
                newValue,
                editorLineHeight: self.appearance.descriptionEditorLineHeight,
                font: self.appearance.descriptionFont
            )
        }
    }

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

extension ProfileAboutServiceView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.stubView)
        self.scrollView.addSubview(self.titleLabel)
        self.scrollView.addSubview(self.descriptionLabel)
        self.scrollView.addSubview(self.versionView)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }

        self.stubView.translatesAutoresizingMaskIntoConstraints = false
        self.stubView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalTo(self.scrollView)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.stubView.snp.bottom).offset(self.appearance.titleOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.titleOffset.left)
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.descriptionOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.descriptionOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.descriptionOffset.right)
        }

        self.versionView.translatesAutoresizingMaskIntoConstraints = false
        self.versionView.snp.makeConstraints { make in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(self.appearance.versionOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.versionOffset.left)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.versionOffset.bottom)
        }
    }
}
