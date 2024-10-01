import SnapKit
import UIKit

extension SearchHeaderView {
    struct Appearance {
        let searchBarBackgroundColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 0.12)
        let searchBarTextColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

        let calendarIconSize = CGSize(width: 36, height: 36)

        var searchBarViewCornerRadius: CGFloat = 6.0

        var backgroundColor = 0x2E3139.themedColor

        var searchBarViewOffset = LayoutInsets(top: -2.0, left: -2.0, bottom: 2.0, right: 2.0)
        var cityButtonOffset = LayoutInsets(top: 2.0, left: 2.0, bottom: -2.0, right: 2.0)
    }
}

final class SearchHeaderView: UIView {
    let appearance: Appearance

    var title: String? {
        didSet {
            self.searchBar.text = self.title
        }
    }

    var hasSearchIcon: Bool = false {
        didSet {
            if self.hasSearchIcon {
                self.addSubview(self.calendarIcon)
                self.calendarIcon.snp.makeConstraints { make in
                    make.trailing.centerY.equalToSuperview()
                    make.size.equalTo(self.appearance.calendarIconSize)
                }

                self.searchBarTrailingConstraint?.activate()
            } else {
                self.calendarIcon.removeFromSuperview()
                self.searchBarTrailingConstraint?.deactivate()
            }
        }
    }

    private lazy var searchBarView = HomeScreenSearchBarView(
        appearance: .init(backgroundColor: appearance.backgroundColor)
    )

    private(set) lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск"
        search.backgroundColor = .clear
        search.barTintColor = .clear
        search.tintColor = self.appearance.searchBarTextColor
        search.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        return search
    }()

    private(set) lazy var calendarIcon = UIImageView(image: #imageLiteral(resourceName: "calendar-button"))

    private var searchBarTrailingConstraint: Constraint?

    var cityButtonTapAction: (() -> Void)?

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        setupView()
        addSubviews()
        makeConstraints()
        setupSearchBar()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSearchBar() {
        searchBarView.cityButtonTapAction = { [weak self] in
            guard let self else { return }
            cityButtonTapAction?()
        }
        searchBarView.setupSearchFieldTapAction(enabled: false)
    }

    func setupSearchField(text: String) {
        searchBarView.setupSearchField(text: text)
    }

    func setupSearchField(delegate: UITextFieldDelegate) {
        searchBarView.setupSearchField(delegate: delegate)
    }

    func setupCityButton(with title: String) {
        searchBarView.setupCityButton(with: title)
    }
}

extension SearchHeaderView: ProgrammaticallyDesignable {
    func setupView() {
        if let searchField = self.searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = appearance.searchBarBackgroundColor
        }
    }

    func addSubviews() {
        if PGCMain.shared.featureFlags.searching.showHomeSearchBar {
            addSubview(searchBarView)
        } else {
            addSubview(searchBar)
            addSubview(calendarIcon)
        }
    }

    func makeConstraints() {
        if PGCMain.shared.featureFlags.searching.showHomeSearchBar {
            searchBarView.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(appearance.searchBarViewOffset.left)
                make.top.equalToSuperview().offset(appearance.searchBarViewOffset.top)
                make.bottom.equalToSuperview().offset(appearance.searchBarViewOffset.bottom)
                make.trailing.equalToSuperview().offset(appearance.searchBarViewOffset.right)
            }
        } else {
            searchBar.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().priorityLow()

                self.searchBarTrailingConstraint = make.trailing.equalTo(self.calendarIcon.snp.leading).constraint
            }
            calendarIcon.snp.makeConstraints { make in
                make.trailing.centerY.equalToSuperview()
                make.size.equalTo(self.appearance.calendarIconSize)
            }
        }
    }
}
