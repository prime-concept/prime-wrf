
import Foundation

extension Encodable {

    /// Converting object to postable JSON
    func toJSONString(_ encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        let result = String(decoding: data, as: UTF8.self)
        return result
    }
}
