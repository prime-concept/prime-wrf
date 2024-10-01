import Foundation

struct BeaconItem: Decodable {
    private let duplicatedUUID: UUID

    private(set) var beacon: Beacon
    let notification: Notification
    let region: Region

    var uuid: UUID {
        if let uuid = UUID(uuidString: self.beacon.id) {
            return uuid
        } else {
            return self.duplicatedUUID
        }
    }

    init(beacon: Beacon, notification: Notification, region: Region) {
        self.beacon = beacon
        self.notification = notification
        self.region = region

        self.duplicatedUUID = UUID()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.beacon = try container.decode(Beacon.self, forKey: .beacon)
        self.notification = try container.decode(Notification.self, forKey: .notification)
        self.region = try container.decode(Region.self, forKey: .region)

        self.duplicatedUUID = UUID()
    }

    enum CodingKeys: String, CodingKey {
        case beacon
        case notification
        case region
    }

    struct Beacon: Decodable {
        typealias IDType = String

        let id: IDType
        let major: String
    }

    struct Notification: Decodable {
        let title: String
        let body: String
    }

    struct Region: Decodable {
        let id: String
    }
}
