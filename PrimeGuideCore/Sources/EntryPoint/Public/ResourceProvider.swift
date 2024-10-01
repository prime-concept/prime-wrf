import UIKit

public protocol ResourceProvider {
    func color(name: String) -> UIColor
    func image(name: String) -> UIImage
}
