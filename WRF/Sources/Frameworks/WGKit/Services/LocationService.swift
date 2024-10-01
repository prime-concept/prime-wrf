import CoreLocation
import Foundation
import MapKit

typealias LocationServiceFetchCompletion = (LocationServiceResult) -> Void
typealias LocationServiceRegionFetchCompletion = (CLRegion) -> Void

enum LocationServiceResult {
    case success(CLLocationCoordinate2D)
    case error(LocationServiceError)
}

enum LocationServiceError: Error {
    case notAllowed
    case restricted
    case systemError(Error)
}

protocol LocationServiceProtocol: AnyObject {
    /// Last fetched location
    var lastLocation: CLLocation? { get }

    /// Check if geo regions monitoring is available
    var canMonitor: Bool { get }

    /// Get current location of the device once
    func fetchLocation(completion: @escaping LocationServiceFetchCompletion)

    /// Continuously get current location of the device
    func startGettingLocation(
        fetchCompletion: @escaping LocationServiceFetchCompletion,
        regionCompletion: LocationServiceRegionFetchCompletion?
    )

    /// Stop getting location of the device.
    /// Should be used after calling `startGettingLocation(completion:)`
    func stopGettingLocation()

    /// Distance in meters from the last fetched location
    func distanceFromLocation(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance?

    /// Start monitoring if user enters the region
    func startMonitoring(for region: CLRegion)

    /// Stop monitoring if user enters the region
    func stopMonitoring(for region: CLRegion)
}

/// Service for handling user location
final class LocationService: CLLocationManager, LocationServiceProtocol {
    enum Settings {
        static let accuracy = kCLLocationAccuracyBest
        static let distanceFilter: CLLocationDistance = 50
    }

    private var oneTimeFetchCompletion: LocationServiceFetchCompletion?
    private var continuousFetchCompletion: LocationServiceFetchCompletion?
    private var regionFetchCompletion: LocationServiceRegionFetchCompletion?

    private(set) var lastLocation: CLLocation?

    static let shared = LocationService()

    var canMonitor: Bool {
        let selfType = type(of: self)
        return selfType.isMonitoringAvailable(for: CLCircularRegion.self)
            && selfType.authorizationStatus() == .authorizedAlways
    }

    override init() {
        super.init()

        self.desiredAccuracy = Settings.accuracy
        self.distanceFilter = Settings.distanceFilter
        self.delegate = self
    }

    func fetchLocation(completion: @escaping LocationServiceFetchCompletion) {
        if let lastLocation = self.lastLocation {
            completion(.success(lastLocation.coordinate))
            return
        }

        self.oneTimeFetchCompletion = completion
        self.requestWhenInUseAuthorization()
        self.startUpdatingLocation()
    }

    func startGettingLocation(
        fetchCompletion: @escaping LocationServiceFetchCompletion,
        regionCompletion: LocationServiceRegionFetchCompletion?
    ) {
        self.continuousFetchCompletion = fetchCompletion
        self.regionFetchCompletion = regionCompletion

        if regionCompletion == nil {
            self.requestWhenInUseAuthorization()
        } else {
            self.requestAlwaysAuthorization()
        }
        self.startUpdatingLocation()
    }

    func stopGettingLocation() {
        self.stopUpdatingLocation()
        self.continuousFetchCompletion = nil
    }

    func distanceFromLocation(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return self.lastLocation?.distance(from: location)
    }

    // MARK: - Private API

    private func update(with result: LocationServiceResult) {
        self.oneTimeFetchCompletion?(result)
        self.continuousFetchCompletion?(result)
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.last else {
            return
        }

        self.lastLocation = location
        self.update(with: .success(location.coordinate))

        self.oneTimeFetchCompletion = nil
        if self.continuousFetchCompletion == nil {
            self.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            self.update(with: .error(.restricted))
        case .denied:
            self.update(with: .error(.notAllowed))
        // Debug only cases
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            print("Unknown authorization status")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        switch error._code {
        case 1:
            self.stopUpdatingLocation()
            self.update(with: .error(.notAllowed))
        default:
            self.update(with: .error(.systemError(error)))
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        self.regionFetchCompletion?(region)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        self.requestState(for: region)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didDetermineState state: CLRegionState,
        for region: CLRegion
    ) {
        print("State check for registered region, unknown = \(state == .unknown), inside = \(state == .inside)")
    }
}
