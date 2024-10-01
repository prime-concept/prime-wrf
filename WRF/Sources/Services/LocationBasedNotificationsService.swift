import CoreLocation
import UIKit
import UserNotifications

protocol LocationBasedNotificationsServiceProtocol: AnyObject {
    func setup()
}

final class LocationBasedNotificationsService: LocationBasedNotificationsServiceProtocol {
    static let shared = LocationBasedNotificationsService(
        locationService: LocationService.shared,
        beaconsEndpoint: BeaconsEndpoint(),
        persistenceService: BeaconItemsPersistenceService()
    )

    private let locationService: LocationServiceProtocol
    private let beaconsEndpoint: BeaconsEndpointProtocol
    private let persistenceService: BeaconItemsPersistenceServiceProtocol

    init(
        locationService: LocationServiceProtocol,
        beaconsEndpoint: BeaconsEndpointProtocol,
        persistenceService: BeaconItemsPersistenceServiceProtocol
    ) {
        self.locationService = locationService
        self.beaconsEndpoint = beaconsEndpoint
        self.persistenceService = persistenceService
    }

    func setup() {
        self.locationService.startGettingLocation(
            fetchCompletion: { _ in },
            regionCompletion: { [weak self] region in
                self?.handle(regionID: region.identifier)
            }
        )

        DispatchQueue.global(qos: .userInitiated).promise {
            self.beaconsEndpoint.retrieve().result
        }.done { items in
            for item in items.items {
                let region = type(of: self).makeRegion(from: item)
                self.locationService.startMonitoring(for: region)

                _ = self.persistenceService.save(item: item)
            }
        }.cauterize()
    }

    private func handle(regionID: String) {
        self.persistenceService.retrieve(by: regionID).done { item in
            guard let item = item else {
                return
            }

            type(of: self).scheduleLocalNotification(for: item)
        }
    }

    private static func scheduleLocalNotification(for item: BeaconItem) {
        if #available(iOS 10.0, *) {
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = item.notification.title
            notificationContent.body = item.notification.body

            let request = UNNotificationRequest(
                identifier: "LocationBasedNotification",
                content: notificationContent,
                trigger: nil
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    assertionFailure("Error while scheduling local notification = \(error)")
                }
            }
        } else {
            let localNotification = UILocalNotification()
            localNotification.alertTitle = item.notification.title
            localNotification.alertBody = item.notification.body
            localNotification.fireDate = Date().addingTimeInterval(1)

            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }

    private static func makeRegion(from beaconItem: BeaconItem) -> CLRegion {
        let region = CLBeaconRegion(
            proximityUUID: beaconItem.uuid,
            major: CLBeaconMajorValue(beaconItem.beacon.major) ?? 0,
            identifier: beaconItem.region.id
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false
        region.notifyEntryStateOnDisplay = true

        return region
    }
}
