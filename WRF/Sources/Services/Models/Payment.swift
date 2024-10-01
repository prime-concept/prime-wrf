import Foundation
import UIKit

extension CardType {
    var image: UIImage? {
        switch self {
        case .master:
            return #imageLiteral(resourceName: "payment-master-card-no-label")
        case .visa:
            return #imageLiteral(resourceName: "payment-visa")
        case .none:
            return nil
        }
    }
}

enum CardType: Int, Codable {
    case visa = 0
    case master = 1
    case none = 2

    enum Key: Int, CodingKey {
        case rawValue
    }
}

struct Payment: Codable {
    let id: String
    let number: String
    let date: String
    let type: CardType

    var hiddenNumber: String {
        return self.number.prefix(7) + " ·· ···· " + self.number.suffix(4)
    }
}
