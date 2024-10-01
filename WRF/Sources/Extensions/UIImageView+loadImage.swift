import Nuke
import UIKit

extension UIImageView {
    func loadImage(from url: URL) {
        Nuke.loadImage(with: url, into: self)
    }
}
