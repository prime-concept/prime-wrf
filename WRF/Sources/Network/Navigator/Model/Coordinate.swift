import CoreLocation
import Foundation

struct Coordinate: Decodable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }

    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
