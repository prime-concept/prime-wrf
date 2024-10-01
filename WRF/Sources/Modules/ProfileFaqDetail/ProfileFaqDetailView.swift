import SnapKit
import UIKit

extension ProfileFaqDetailView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 17)
        let titleEditorLineHeight: CGFloat = 20
        var titleColor = Palette.shared.textPrimary
        let titleOffset = LayoutInsets(top: 25, left: 15, right: 15)

        let textFont = UIFont.wrfFont(ofSize: 15)
        let textEditorLineHeight: CGFloat = 22
        var textColor = Palette.shared.textPrimary
        let textOffset = LayoutInsets(top: 20, left: 15, bottom: 25, right: 15)

        let imageHeight: CGFloat = 240
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileFaqDetailView: UIView {
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

    var text: String? {
        didSet {
            self.textLabel.attributedText = LineHeightStringMaker.makeString(
                self.text ?? "",
                editorLineHeight: self.appearance.textEditorLineHeight,
                font: self.appearance.textFont
            )
        }
    }

    private(set) lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        }
        return scroll
    }()

    private lazy var headerView = ProfileFaqDetailHeaderView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.textFont
        label.textColorThemed = self.appearance.textColor
        return label
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

extension ProfileFaqDetailView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.headerView)
        self.scrollView.addSubview(self.titleLabel)
        self.scrollView.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.imageHeight)
            make.width.equalTo(self.scrollView)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.titleOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.titleOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleOffset.right)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.textOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.textOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.textOffset.right)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.textOffset.bottom)
        }
    }
}
