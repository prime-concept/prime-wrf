import DeviceKit
import GoogleMaps
import UIKit

protocol MapViewControllerProtocol: AnyObject {
    func set(restaurants: [MapRestaurantViewModel])
    func set(tags: [MapTagViewModel])

    func updateFilter(count: Int)
    func updateNotification(count: Int)

    func present(restaurant: Restaurant, assessment: PrimePassAssessment?)
    func present(filterIDs: [Tag.IDType])

    func set(myLocationEnabled: Bool)

    func showNotificationButton()
    func showCurrentLocation()
    func showLocationSettings()
    func deselectSelectedTag()
}

final class MapViewController: UIViewController {

    private static let mapZoom: Float = 17.0
    private static let minimumDistanceToZoomOut: CLLocationDistance = 15000

    private enum Appearance {
        static let defaultTopOffset: CGFloat = 15
        static let smallTopOffset: CGFloat = 8

        static let restaurantsContainerHeight: CGFloat = 350
        static let largeRestaurantsContainerHeight: CGFloat = 446

        static let mapStyle = """
            [
              {
                "featureType": "poi.attraction",
                "stylers": [
                  {
                    "visibility": "off"
                  }
                ]
              },
              {
                "featureType": "poi.business",
                "stylers": [
                  {
                    "visibility": "off"
                  }
                ]
              }
            ]
        """

        static let citiesCurtainHeight: CGFloat = UIScreen.main.bounds.height - 150

        static let citiesViewBackgroundColor = Palette.shared.backgroundColor0
    }

    static var currentRestaurantsContainerHeight: CGFloat {
        return Device.current.diagonal >= 5.5
            ? Appearance.largeRestaurantsContainerHeight
            : Appearance.restaurantsContainerHeight
    }

    static var currentTopOffset: CGFloat {
        return Device.current.hasSensorHousing
            ? Appearance.smallTopOffset
            : Appearance.defaultTopOffset
    }

    let presenter: MapPresenterProtocol
    lazy var mapView = self.view as? MapView
    private var currentCity: SearchCityViewModel?

    private lazy var restaurantPresentationManager = FloatingControllerPresentationManager(
        context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
        groupID: RestaurantViewController.floatingControllerGroupID,
        sourceViewController: self
    )

    private lazy var searchPresentationManager = FloatingControllerPresentationManager(
        context: .search(height: SearchViewController.Appearance.controllerHeight),
        groupID: SearchViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private lazy var filterPresentationManager = FloatingControllerPresentationManager(
        context: .filter,
        groupID: MapFilterViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private lazy var googleMapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(
            withLatitude: 55.751_244,
            longitude: 37.618_423,
            zoom: MapViewController.mapZoom
        )
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = [.authorizedWhenInUse, .authorizedAlways]
            .contains(CLLocationManager.authorizationStatus())
        mapView.mapStyle = try? GMSMapStyle(jsonString: Appearance.mapStyle)
        mapView.delegate = self
        mapView.padding = UIEdgeInsets(
            top: type(of: self).currentTopOffset,
            left: 0,
            bottom: type(of: self).currentRestaurantsContainerHeight,
            right: 0
        )
        return mapView
    }()

    private var currentRestaurantCellIndex = 0
    private var currentTagCellIndex = 0
    private var restaurants: [MapRestaurantViewModel] = []
    private var tags: [MapTagViewModel] = []
    private var markersToRestaurants: [Int: Int] = [:]
    private var restaurantsToMarkers: [Int: GMSMarker] = [:]

    var cellHeight: CGFloat {
        return self.mapView?.appearance.restaurantsCellHeight ?? 1
    }

    init(presenter: MapPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let appearance = MapView.Appearance(
            restaurantsContainerHeight: type(of: self).currentRestaurantsContainerHeight,
            topOffset: type(of: self).currentTopOffset
        )
        let view = MapView(frame: UIScreen.main.bounds, appearance: appearance)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setBackButtonText()

        self.edgesForExtendedLayout = [.top]

        self.mapView?.updateMapView(view: self.googleMapView)

        self.presenter.loadTags()
        self.presenter.loadRestaurants()
        self.presenter.loadNotifications()

        self.mapView?.updateTableView(delegate: self, dataSource: self)
        self.mapView?.resetTableView()

        self.mapView?.updateTagsCollectionView(delegate: self, dataSource: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getCurrentCityName { [weak self] city in
            self?.currentCity = city
            self?.mapView?.setupCityButton(title: city?.title ?? "Город")
        }
    }

    // MARK: - Private API

    private func contentOffset(for index: Int) -> CGFloat {
        return CGFloat(index) * self.cellHeight
    }

    private func updateMarkersAppearance() {
        self.googleMapView.clear()
        self.markersToRestaurants.removeAll()
        self.restaurantsToMarkers.removeAll()

        for (index, viewModel) in self.restaurants.enumerated() {
            guard let location = viewModel.location else { return }

            let marker = GMSMarker(position: location)
            marker.isTappable = true
            marker.map = self.googleMapView
            self.updateMarkerAppearance(marker: marker, isSelected: index == 0)

            self.markersToRestaurants[marker.hash] = index
            self.restaurantsToMarkers[index] = marker
        }
    }

    private func updateCamera() {
        guard let location = self.restaurants[safe: self.currentRestaurantCellIndex]?.location else {
            return
        }

        // if distance to restaurant > 15km, fit bounds to show both restaurant and user on map
        if let myLocation = self.googleMapView.myLocation {
            let restaurantLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let distance = myLocation.distance(from: restaurantLocation)
            if distance >= MapViewController.minimumDistanceToZoomOut {
                let bounds = GMSCoordinateBounds(coordinate: myLocation.coordinate, coordinate: location)
                self.googleMapView.animate(with: GMSCameraUpdate.fit(bounds))
                return
            }
        }
        self.googleMapView.animate(toLocation: location)
    }

    private func updateSelectedMarker() {
        for (key, value) in self.restaurantsToMarkers {
            self.updateMarkerAppearance(marker: value, isSelected: key == self.currentRestaurantCellIndex)
        }
    }

    private func updateMarkerAppearance(marker: GMSMarker, isSelected: Bool) {
        marker.icon = isSelected ? UIImage(named: "map-marker-3") : UIImage(named: "map-marker-3-light")
    }

    private func openSettingsDialog(title: String, message: String?) {
        let dialog = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let settingsAction = UIAlertAction(title: "Перейти", style: .default) { _ in
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=\(bundleId)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        dialog.addAction(cancelAction)
        dialog.addAction(settingsAction)
        dialog.popoverPresentationController?.sourceView = self.view
        self.present(dialog, animated: true)
    }

    private func getCurrentCityName(completion: @escaping (SearchCityViewModel?) -> Void) {
        guard 
            let location = googleMapView.myLocation
        else {
            completion(nil)
            return
        }

        let currentLocation = CLLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )

        CLGeocoder().reverseGeocodeLocation(currentLocation) { placemarks, _ in
            guard  let cityName = placemarks?.first?.locality else {
                completion(nil)
                return
            }
            completion(SearchCityViewModel(
                id: "0",
                title: cityName,
                coordinates: .init(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            ))
        }
    }

}

extension MapViewController: UITableViewDelegate {
    private func updateCurrentRestaurantCellIndex(_ scrollView: UIScrollView) {
        self.currentRestaurantCellIndex = max(
            0,
            min(self.restaurants.count - 1, Int((scrollView.contentOffset.y) / self.cellHeight))
        )
    }

    private func updateAfterScrollingEnd(scrollView: UIScrollView) {
        guard scrollView.contentOffset.y >= 0.0 else {
            return
        }

        self.updateCurrentRestaurantCellIndex(scrollView)

        guard let tableView = scrollView as? UITableView else {
            return
        }

        if self.currentRestaurantCellIndex == tableView.numberOfRows(inSection: 0) - 1 {
            self.mapView?.scrollToRestaurant(index: self.currentRestaurantCellIndex)
        } else {
            let contentOffset = scrollView.contentOffset.y
            let currentCellOffset = self.contentOffset(for: self.currentRestaurantCellIndex)
            let nextCellOffset = self.contentOffset(for: self.currentRestaurantCellIndex + 1)

            if abs(nextCellOffset - contentOffset).isLess(than: abs(currentCellOffset - contentOffset)) {
                self.mapView?.scrollToRestaurant(index: self.currentRestaurantCellIndex + 1)
            } else {
                self.mapView?.scrollToRestaurant(index: self.currentRestaurantCellIndex)
            }
        }

        self.updateCamera()
        self.updateSelectedMarker()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.updateCurrentRestaurantCellIndex(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updateAfterScrollingEnd(scrollView: scrollView)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.updateAfterScrollingEnd(scrollView: scrollView)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.updateAfterScrollingEnd(scrollView: scrollView)
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        self.updateAfterScrollingEnd(scrollView: scrollView)
    }
}

extension MapViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MapRestaurantsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MapRestaurantsTableViewCell,
              let viewModel = self.restaurants[safe: indexPath.row] else {
            return
        }

        cell.isSelected = self.currentRestaurantCellIndex == indexPath.row
        cell.configure(with: viewModel, isSmall: Device.current.diagonal <= 4.0)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let viewModel = self.restaurants[safe: indexPath.row] {
            self.presenter.selectRestaurant(id: viewModel.id)
        }
    }
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = self.tags[safe: indexPath.row] else {
            return .zero
        }

        let view = SubtitleTagItemView()
        view.title = viewModel.title

        view.translatesAutoresizingMaskIntoConstraints = false
        view.setNeedsLayout()
        view.layoutIfNeeded()

        let height = self.mapView?.appearance.tagsViewHeight ?? 0
        return CGSize(width: view.bounds.width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentTagCellIndex = indexPath.row

        for currentIndexPath in collectionView.indexPathsForVisibleItems {
            guard let cell = collectionView.cellForItem(at: currentIndexPath) as? MapTagsCollectionViewCell else {
                continue
            }

            cell.isSelected = currentIndexPath == indexPath
        }

        if let viewModel = self.tags[safe: indexPath.row] {
            self.presenter.selectTag(id: viewModel.id)
        }

        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension MapViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionView.layoutIfNeeded() // Workaround: crash on iPhone Plus iOS 10
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tags.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: MapTagsCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)

        guard let viewModel = self.tags[safe: indexPath.row] else {
            return cell
        }

        cell.isSelected = self.currentTagCellIndex == indexPath.row
        cell.configure(with: viewModel)

        return cell
    }
}

extension MapViewController: MapViewDelegate {
    func mapViewDidSelectSearch(_ view: MapView) {
    
        self.presenter.didActivateSearchMode()
    
        let searchController = SearchAssembly().makeModule()
        self.searchPresentationManager.contentViewController = searchController
        self.searchPresentationManager.present()

        if let searchViewController = searchController as? SearchViewController {
            searchViewController.searchControllerPresentator = SearchControllerPresentator(
                manager: self.searchPresentationManager
            )
        }
    }

    func mapViewDidSelectCurrentLocation(_ view: MapView) {
        self.presenter.handleCurrentLocationRequest()
    }

    func mapViewDidSelectFilter(_ view: MapView) {
        self.presenter.selectFilter()
    }

    func mapViewDidSelectNotifications(_ view: MapView) {
        let notificationsController = NotificationsAssembly().makeModule()
        self.navigationController?.pushViewController(notificationsController, animated: true)
        self.updateNotification(count: 0)
        self.presenter.didTransitionToNotifications()
    }

    func mapViewDidTapCity(_ view: MapView) {
        let assembly = SearchCityAssembly()
        assembly.selectedCity = currentCity

        guard
            let searchCityViewController = assembly.makeModule() as? SearchCityViewController
        else {
            return
        }

        searchCityViewController.view.snp.makeConstraints { make in
            make.height.equalTo(Appearance.citiesCurtainHeight)
        }

        let curtain = CurtainViewController(
            with: UIStackView.vertical(searchCityViewController.view),
            backgroundColor: Palette.shared.clear,
            curtainViewBackgroundColor: Appearance.citiesViewBackgroundColor
        )
        curtain.addChild(searchCityViewController)

        searchCityViewController.citySelectedCallback = { [weak self] city in
            self?.currentCity = city
            self?.mapView?.setupCityButton(title: city.title)
            self?.showLocation(of: city)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                curtain.dismiss(animated: true)
            }
        }

        curtain.present(animated: false)
    }

    func mapViewDidTapClose(_ view: MapView) {
        dismiss(animated: true)
    }
}

extension MapViewController: MapViewControllerProtocol {
    func set(restaurants: [MapRestaurantViewModel]) {
        self.restaurants = restaurants
        self.mapView?.updateTableView(delegate: self, dataSource: self)
        self.mapView?.hideLoading()

        self.updateMarkersAppearance()
        self.updateCamera()
    }

    func set(tags: [MapTagViewModel]) {
        self.tags = tags
        self.mapView?.updateTagsCollectionView(delegate: self, dataSource: self)
    }

    func updateNotification(count: Int) {
        self.mapView?.notificationCount = count
    }

    func updateFilter(count: Int) {
        self.mapView?.filterCount = count
    }

    func present(restaurant: Restaurant, assessment: PrimePassAssessment?) {
        let assembly = RestaurantAssembly(restaurant: restaurant, assessment: assessment)
        let restaurantController = assembly.makeModule()
        self.restaurantPresentationManager.contentViewController = restaurantController
        self.restaurantPresentationManager.present()

        if let restaurantViewController = restaurantController as? RestaurantViewController {
            restaurantViewController.restaurantControllerPresentator = RestaurantControllerPresentator(
                manager: self.restaurantPresentationManager
            )
            self.restaurantPresentationManager.track(scrollView: assembly.trackedScrollView)
        }
    }

    func present(filterIDs: [Tag.IDType]) {
        let filterController = MapFilterAssembly(selectedFilterIDs: filterIDs).makeModule()
        self.filterPresentationManager.contentViewController = filterController
        self.filterPresentationManager.present()

        if let filterViewController = filterController as? MapFilterViewController {
            filterViewController.filterDelegate = self
        }
    }

    func set(myLocationEnabled: Bool) {
        self.googleMapView.isMyLocationEnabled = myLocationEnabled
    }

    func showNotificationButton() {
        self.mapView?.isNotificationEnabled = true
    }

    func deselectSelectedTag() {
        guard let collectionView = self.mapView?.tagsCollectionView else {
            return
        }
        for indexPath in collectionView.indexPathsForVisibleItems
            where indexPath.row == self.currentTagCellIndex {
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.isSelected = false
        }
        // -1 for deselected state
        self.currentTagCellIndex = -1
    }

    func showCurrentLocation() {
        guard let lat = self.googleMapView.myLocation?.coordinate.latitude,
              let lon = self.googleMapView.myLocation?.coordinate.longitude else {
            return
        }

        self.googleMapView.moveCamera(
            GMSCameraUpdate.setTarget(.init(latitude: lat, longitude: lon), zoom: MapViewController.mapZoom)
        )
    }

    func showLocation(of city: SearchCityViewModel) {
        googleMapView.moveCamera(
            GMSCameraUpdate.setTarget(
                .init(
                    latitude: city.coordinates.latitude,
                    longitude: city.coordinates.longitude
                ),
                zoom: MapViewController.mapZoom
            )
        )
    }

    func showLocationSettings() {
        self.openSettingsDialog(
            title: "Запрос на уведомления",
            message: "Изменить параметры уведомлений в настройках"
        )
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let index = self.markersToRestaurants[marker.hash] {
            self.currentRestaurantCellIndex = index
            self.mapView?.scrollToRestaurant(index: index)
            self.updateSelectedMarker()
        }
        return true
    }
    
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            AnalyticsReportingService.shared.didMoveMapView()
        }
    }
}

extension MapViewController: MapFilterViewDelegate {
    func filterViewDidSelectTags(tags: [TypedTag]) {
        self.presenter.loadRestaurants(by: tags)
    }
}
