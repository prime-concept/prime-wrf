import SnapKit
import UIKit

final class SearchCityView: UIView {

    // MARK: - constants

    private enum Appearance {
        static let backgroundColor = Palette.shared.backgroundColor0
        static let headerViewColor = UIColor.clear
        static let searchBarTextColor = UIColor.white.withAlphaComponent(0.8)
        static let emptyViewTextColor = UIColor.systemGray2
        static let emptyViewTopOffset: CGFloat = 20.0
        static let headerHeight: CGFloat = 23.0
    }

    // MARK: - types

    private enum Sections: Int, CaseIterable {
        case currentCity
        case otherCities

        var title: String {
            switch self {
            case .currentCity:
                "Вы здесь".uppercased()
            case .otherCities:
                "Все города".uppercased()
            }
        }
    }

    // MARK: - subviews

    private lazy var loadingIndicator = {
        let loader = WineLoaderView()
        return loader
    }()

    private(set) lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.delegate = self
        search.placeholder = "Название города"
        search.backgroundColorThemed = Appearance.backgroundColor
        search.barTintColor = Appearance.backgroundColor.rawValue
        search.tintColor = Appearance.searchBarTextColor
        return search
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(cellClass: SearchCityCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var emptyStateView: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = Appearance.emptyViewTextColor
        label.text = """
        Хм, мы ничего не нашли.
        Попробуйте изменить параметры поиска
        """
        return label
    }()

    // MARK: - fields

    private var cities: [SearchCityViewModel] = [] {
        didSet {
            showEmptyViewIfNeeded()
        }
    }
    private var filteredCities: [SearchCityViewModel] = [] {
        didSet {
            showEmptyViewIfNeeded()
        }
    }
    private var isSearching = false

    private var selectedCity: SearchCityViewModel?

    // MARK: - callbacks

    var dismiss: (() -> Void)?
    var citySelected: ((SearchCityViewModel) -> Void)?

    // MARK: - life cycle

    init() {
        super.init(frame: .zero)
        setupView()
        addSubviews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setup

    func setup(cities: [SearchCityViewModel], currentCity: SearchCityViewModel?) {
        self.cities = cities
        selectedCity = currentCity
        hideLoading()
        setupView()
        tableView.reloadData()
    }

    // MARK: - configure

    private func setupView() {
        backgroundColorThemed = Appearance.backgroundColor
        tableView.isHidden = cities.isEmpty
        emptyStateView.isHidden = !cities.isEmpty
    }

    private func addSubviews() {
        addSubview(emptyStateView)
        addSubview(searchBar)
        addSubview(tableView)
        addSubview(loadingIndicator)
    }

    private func makeConstraints() {
        emptyStateView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(Appearance.emptyViewTopOffset)
            make.leading.trailing.equalToSuperview()
        }
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // MARK: - actions

    private func hideLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadingIndicator.stopAnimating()
        }
    }

    private func showEmptyViewIfNeeded() {
        let isTableViewShown = !cities.isEmpty && (!isSearching || !filteredCities.isEmpty)

        tableView.isHidden = !isTableViewShown
        emptyStateView.isHidden = isTableViewShown
    }
}

// MARK: - UITableViewDelegate

extension SearchCityView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let city = isSearching
                ? filteredCities[safe: indexPath.row]
                : cities[safe: indexPath.row]
        {
            selectedCity = city
            citySelected?(city)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.dismiss?()
        }
        tableView.reloadData()
    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let headerView = SearchCityTableHeaderView()
        headerView.configure(with: Sections(rawValue: section)?.title ?? "")
        return headerView
    }

    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        Appearance.headerHeight
    }
}

// MARK: - UITableViewDataSource

extension SearchCityView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        cities.isEmpty || isSearching
        ? 1
        : Sections.allCases.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        Sections(rawValue: section) == .currentCity
        ? 1
        : cities.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchCityCell.defaultReuseIdentifier,
                for: indexPath
            ) as? SearchCityCell,
            let city = isSearching
                ? filteredCities[safe: indexPath.row]
                : cities[safe: indexPath.row]
        else {
            return UITableViewCell()
        }

        let isCellChecked = isSearching
        ? selectedCity == filteredCities[safe: indexPath.row]
        : selectedCity == cities[safe: indexPath.row]

        cell.setup(
            with: .init(
                title: city.title,
                distance: nil,
                isCheckmarkVisible: isCellChecked
            )
        )
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        isSearching
        ? nil
        : Sections(rawValue: section)?.title ?? ""
    }
}

// MARK: - UISearchBarDelegate

extension SearchCityView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredCities = []
        } else {
            isSearching = true
            filteredCities = cities.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        tableView.reloadData()
    }
}
