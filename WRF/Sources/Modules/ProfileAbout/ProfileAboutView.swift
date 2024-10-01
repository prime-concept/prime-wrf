import SnapKit
import UIKit

extension ProfileAboutView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 17)
        var titleColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 20
        let titleTopOffset: CGFloat = 25
        let descriptionOffset = LayoutInsets(top: 20, left: 15, bottom: 0, right: 15)

        let descriptionBottomOffset = 16
        let versionOffset = LayoutInsets(left: 15, bottom: 10)
        let socialsTopOffset: CGFloat = 40
        let headerHeight: CGFloat = 240
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileAboutView: UIView {
    let appearance: Appearance

    private(set) lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        }
        return scroll
    }()

    private lazy var headerView = ProfileAboutHeaderView()
    private lazy var socialsView = ProfileAboutSocialsView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
        label.attributedText = LineHeightStringMaker.makeString(
            PGCMain.shared.text.aboutTitle,
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        return label
    }()

    private lazy var descriptionLabel: RestaurantDescriptionView = {
        var appearance: RestaurantDescriptionView.Appearance = ApplicationAppearance.appearance()
        appearance.insets = self.appearance.descriptionOffset
        let view = RestaurantDescriptionView(appearance: appearance)
        view.text = PGCMain.shared.text.about
        view.isAlwaysExpanded = true
        return view
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

extension ProfileAboutView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.headerView)
        self.scrollView.addSubview(self.titleLabel)
        self.scrollView.addSubview(self.descriptionLabel)
    }

    func makeConstraints() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }

        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.headerHeight)
            make.width.equalTo(self.scrollView)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.titleTopOffset)
            make.centerX.equalToSuperview()
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.descriptionBottomOffset)
        }
    }
}
