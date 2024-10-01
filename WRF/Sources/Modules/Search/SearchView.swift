import SnapKit
import Tabman
import UIKit

protocol SearchViewDelegate: AnyObject {
    func searchViewDidChooseCalendar(_ view: SearchView)
}

extension SearchView {
    struct Appearance {
        let tabBarWeight: CGFloat = 1
        let tabBarTintColor = Palette.shared.strokeStrong
        let tabBarHeight: CGFloat = 111
        let tabBarColor = Palette.shared.backgroundColor0

        let tabContainerTopOffset: CGFloat = 5

        let separatorHeight: CGFloat = 1
        let separatorColor = Palette.shared.strokeSecondary

        let headerOffset = LayoutInsets(top: 25, left: 10, right: 15)
        let headerHeight: CGFloat = 36

        let tabContentTopOffset: CGFloat = 126

        let backgroundColor = Palette.shared.backgroundColor0
    }
}

final class SearchView: UIView {
    let appearance: Appearance

    weak var delegate: SearchViewDelegate?

    var title: String? {
        didSet {
            self.headerView.title = self.title
        }
    }

    var showsCalendar: Bool = false {
        didSet {
            self.headerView.hasSearchIcon = self.showsCalendar
        }
    }

    private(set) lazy var headerView: SearchHeaderView = {
        let view = SearchHeaderView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.calendarClicked))
        view.calendarIcon.isUserInteractionEnabled = true
        view.calendarIcon.addGestureRecognizer(tap)
        return view
    }()

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

    // MARK: - Public API

    func makeTabBar() -> TMBar.WRFBar {
        let bar = TMBar.WRFBar()
        bar.layout.contentMode = .fit
        bar.layout.transitionStyle = .none
        bar.backgroundView.style = .clear
        bar.indicator.weight = .custom(value: self.appearance.tabBarWeight)
        bar.indicator.tintColorThemed = self.appearance.tabBarTintColor
        return bar
    }

    // MARK: - Private API

    @objc
    private func calendarClicked() {
        self.delegate?.searchViewDidChooseCalendar(self)
    }

    func setupSearchField(delegate: UITextFieldDelegate) {
        headerView.setupSearchField(delegate: delegate)
    }

    func setupCityButton(with title: String) {
        headerView.setupCityButton(with: title)
    }
}

extension SearchView: ProgrammaticallyDesignable {
    func setupView() {
        backgroundColorThemed = appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tabContainerView)
        self.tabContainerView.addSubview(self.headerView)
        self.tabContainerView.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.tabContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.tabBarHeight)
        }

        self.headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.headerOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.headerOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.headerOffset.right)
            make.height.equalTo(self.appearance.headerHeight)
        }

        self.separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
