import PromiseKit
import UIKit

extension UIImage {
    func resize(to size: CGSize) -> Guarantee<UIImage?> {
        return Guarantee<UIImage?> { seal in
            let originalSize = self.size
            var newSize = size

            if originalSize.width < newSize.width && originalSize.height < newSize.height {
                seal(self)
                return
            }

            let scale = originalSize.width / originalSize.height
            if scale < 1 {
                newSize.height = newSize.width / scale
            } else {
                newSize.width = newSize.height * scale
            }

            UIGraphicsBeginImageContext(newSize)
            self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if let resizedImage = resizedImage {
                seal(resizedImage)
                return
            }
            seal(nil)
        }
    }
}
