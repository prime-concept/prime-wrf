import UIKit

class WineLoaderView: UIImageView {
    convenience init() {
        self.init(frame: CGRect.zero)
        let imageNames = (0...40).map { "wine-loader-\($0)" }
        animationImages = imageNames.compactMap { UIImage(named: $0) }
        animationRepeatCount = -1
        animationDuration = 1
        DispatchQueue.main.async { [weak self] in
            self?.startAnimating()
        }
        contentMode = .scaleAspectFill
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 200)
    }

    override func startAnimating() {
        super.startAnimating()
        isHidden = false
    }

    override func stopAnimating() {
        super.stopAnimating()
        isHidden = true
    }
}
