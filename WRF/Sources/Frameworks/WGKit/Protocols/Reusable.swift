import UIKit

public protocol Reusable: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

public extension Reusable where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
