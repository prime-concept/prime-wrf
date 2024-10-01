import UIKit

protocol RestaurantLocationViewControllerProtocol: AnyObject {
    func set(model: RestaurantLocationsViewModel)
}

final class RestaurantLocationViewController: UIViewController {
    let presenter: RestaurantLocationPresenterProtocol
    private lazy var locationsView = self.view as? RestaurantLocationView

    private var viewModel: RestaurantLocationsViewModel?
    private weak var moduleOutput: RestaurantLocationModuleOutput?

    init(
        presenter: RestaurantLocationPresenterProtocol,
        moduleOutput: RestaurantLocationModuleOutput? = nil
    ) {
        self.presenter = presenter
        self.moduleOutput = moduleOutput
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = RestaurantLocationView()
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter.loadLocations()
    }
}

extension RestaurantLocationViewController: RestaurantLocationViewControllerProtocol {
    func set(model: RestaurantLocationsViewModel) {
        self.viewModel = model
        self.locationsView?.address = model.address
        self.locationsView?.taxiPrice = model.taxi?.price

        self.moduleOutput?.isTaxiAvailable(available: model.taxi != nil)
    }
}

extension RestaurantLocationViewController: RestaurantLocationViewDelegate {
    // swiftlint:disable:next cyclomatic_complexity
    func restaurantLocationViewDidRequestRoute(_ view: RestaurantLocationView) {
        
        self.presenter.didTapOpenRoute()
        
        struct MapApplication {
            let title: String
            let openClosure: (Double, Double, String) -> Void
            let canOpenClosure: () -> Bool
        }

        guard let coordinate = self.viewModel?.coordinate,
              let place = (self.viewModel?.placeTitle)
                .flatMap({ $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }) else {
            return
        }

        let applications: [MapApplication] = [
            MapApplication(
                title: "Яндекс.Карты",
                openClosure: { latitude, longitude, place in
                    guard let url = URL(
                        string: "yandexmaps://maps.yandex.ru/?ll=\(coordinate.longitude),\(coordinate.latitude)&z=17&text=\(place)"
                    ) else {
                        return
                    }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                canOpenClosure: {
                    guard let url = URL(string: "yandexmaps://") else {
                        return false
                    }

                    return UIApplication.shared.canOpenURL(url)
                }
            ),
            MapApplication(
                title: "Google Карты",
                openClosure: { latitude, longitude, place in
                    guard let url = URL(
                        string: "comgooglemaps://?center=\(coordinate.latitude),\(coordinate.longitude)&q=\(place)&z=18.7"
                    ) else {
                        return
                    }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                canOpenClosure: {
                    guard let url = URL(string: "comgooglemaps://") else {
                        return false
                    }

                    return UIApplication.shared.canOpenURL(url)
                }
            ),
            MapApplication(
                title: "Карты",
                openClosure: { latitude, longitude, place in
                    guard let url = URL(
                        string: "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)&q=\(place)&z=21"
                    ) else {
                        return
                    }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                },
                canOpenClosure: {
                    guard let url = URL(string: "http://maps.apple.com") else {
                        return false
                    }

                    return UIApplication.shared.canOpenURL(url)
                }
            )
        ]

        let availableApplications = applications.filter { $0.canOpenClosure() }

        if availableApplications.isEmpty {
            let fallbackPath = "https://www.google.com/maps/?q=@\(coordinate.latitude),\(coordinate.longitude)&zoom=18.7"
            guard let url = URL(string: fallbackPath) else {
                return
            }

            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if availableApplications.count > 1 {
            let alert = UIAlertController(
                title: "Открыть в приложении",
                message: nil,
                preferredStyle: .actionSheet
            )
            for app in availableApplications {
                let button = UIAlertAction(
                    title: app.title,
                    style: .default,
                    handler: { _ in
                        app.openClosure(coordinate.latitude, coordinate.longitude, place)
                    }
                )
                alert.addAction(button)
            }

            let cancelAction = UIAlertAction(title: "Закрыть", style: .cancel)
            alert.addAction(cancelAction)

            alert.popoverPresentationController?.sourceView = self.view

            self.present(alert, animated: true, completion: nil)
        } else {
            availableApplications.first?.openClosure(coordinate.latitude, coordinate.longitude, place)
        }
    }

    func restaurantLocationViewDidRequestTaxiCall(_ view: RestaurantLocationView) {
        guard let path = self.viewModel?.taxi?.url, let url = URL(string: path) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
