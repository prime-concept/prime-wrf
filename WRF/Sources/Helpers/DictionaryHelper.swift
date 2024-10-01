import Foundation

enum DictionaryHelper {
    static func makeDictionary<T: Encodable>(from object: T) -> [String: Any] {
        // Alamofire doesn't support Codable so we should get dictionary (e. g. for Parameters)
        // swiftlint:disable force_try force_cast
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try! encoder.encode(object)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        // swiftlint:enable force_try force_cast
        return dictionary
    }

    static func makeObject<T: Decodable>(from dictionary: [String: Any]) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // swiftlint:disable force_try
        let data = try! JSONSerialization.data(withJSONObject: dictionary)
        // swiftlint:enable force_try
        return try? decoder.decode(T.self, from: data)
    }
}
