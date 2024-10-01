import PromiseKit
import UIKit

extension UIImage {
    private static let defaultQuality: CGFloat = 1

    func asBase64String(quality: CGFloat = UIImage.defaultQuality) -> Guarantee<String?> {
        return Guarantee<String?> { seal in
            if let imageData = self.jpegData(compressionQuality: quality) {
               let base64 = imageData.base64EncodedString()
                seal(base64)
                return
            }
            seal(nil)
        }
    }
}
