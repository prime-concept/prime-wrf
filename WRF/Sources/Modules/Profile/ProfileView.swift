import UIKit

extension ProfileView {
    struct Appearance: Codable {
        var tabBarHeight: CGFloat = 45
        var tabBarColor = Palette.shared.backgroundColor0

        var separatorHeight: CGFloat = 1
        var separatorColor = Palette.shared.strokeSecondary

        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileView: UIView {
    let appearance: Appearance

    private(set) lazy var tabContainerView: UIView = {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.tabBarColor
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.separatorColor
        return view
    }()

    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColorThemed = self.appearance.backgroundColor
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

extension ProfileView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tabContainerView)
        self.tabContainerView.addSubview(self.separatorView)
        self.addSubview(contentView)
    }

    func makeConstraints() {
        self.tabContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.tabContainerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.tabBarHeight)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        contentView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.bottom.leading.trailing.bottom.equalToSuperview()
        }
    }
}
