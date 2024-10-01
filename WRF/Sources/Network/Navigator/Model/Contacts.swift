import Foundation

struct Contacts: Codable {
    let items: [Contact]

    struct Contact: Codable {
        enum FieldType: String, Codable {
            case email
            case phone
        }

        let title: String?
        let value: String?
        let type: FieldType?
    }
}
