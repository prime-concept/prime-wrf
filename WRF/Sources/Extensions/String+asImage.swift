import UIKit

extension String {
    var asImage: UIImage? {
        var base64String = self

        if self.prefix(4) == "data", let commaIndex = self.firstIndex(of: ",") {
            base64String = String(self.suffix(from: self.index(after: commaIndex)))
        }
        if let imageData = Data(base64Encoded: base64String),
           let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
}