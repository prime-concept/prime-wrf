import UIKit

protocol SearchCityViewControllerProtocol: UIViewController {

}

final class SearchCityViewController: UIViewController {

    // MARK: - constants

    enum Constants {
        static let cornerRadius: CGFloat = 20.0
    }

    // MARK: - subviews

    private var searchCityView: SearchCityView? {
        view as? SearchCityView
    }

    // MARK: - fields

    private var presenter: SearchCityPresenterProtocol
    private var selectedCity: SearchCityViewModel?

    // MARK: - callbacks

    var citySelectedCallback: ((SearchCityViewModel) -> Void)?

    // MARK: - life cycle

    init(
        presenter: SearchCityPresenterProtocol,
        selectedCity: SearchCityViewModel?
    ) {
        self.presenter = presenter
        self.selectedCity = selectedCity
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SearchCityView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configurePresenter()
        presenter.viewDidLoad()
    }

    // MARK: - configurations

    private func configureView() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = Constants.cornerRadius
        searchCityView?.citySelected = { [weak self] city in
            self?.citySelectedCallback?(city)
        }
    }

    private func configurePresenter() {
        presenter.citiesCallback = { [weak self] search in
            self?.searchCityView?
                .setup(
                    cities: search.cities,
                    currentCity: self?.selectedCity
                )
        }
    }
}

// MARK: - SearchCityViewControllerProtocol

extension SearchCityViewController: SearchCityViewControllerProtocol {

}
