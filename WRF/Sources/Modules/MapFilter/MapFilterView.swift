import SnapKit
import Tabman
import UIKit

extension MapFilterView {
    struct Appearance {
        let tabBarHeight: CGFloat = 60
        let tabBarColor = UIColor.white
        let tabBarTintColor = UIColor.black
        let tabBarWeight: CGFloat = 1

        let tabBarTopOffset: CGFloat = 15

        // tabBarHeight + top 25 offset
        let tabContentTopOffset: CGFloat = 70

        let separatorHeight: CGFloat = 1
        let separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    }
}

final class MapFilterView: UIView {
    let appearance: Appearance

    private(set) lazy var tabContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.tabBarColor
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
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

    // MARK: - Public api

    func makeTabBar() -> TMBar.WRFBar {
        let bar = TMBar.WRFBar()
        bar.layout.contentMode = .fit
        bar.layout.transitionStyle = .none
        bar.backgroundView.style = .clear
        bar.indicator.weight = .custom(value: self.appearance.tabBarWeight)
        bar.indicator.tintColor = self.appearance.tabBarTintColor
        return bar
    }
}

extension MapFilterView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.tabContainerView)
        self.tabContainerView.addSubview(self.separatorView)
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
    }
}
