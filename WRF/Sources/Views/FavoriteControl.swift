import UIKit

final class FavoriteControl: UIControl {
    private enum Appearance {
        static let size = CGSize(width: 44, height: 44)
    }

    override var intrinsicContentSize: CGSize {
        return Appearance.size
    }

    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.layer.contents = #imageLiteral(resourceName: "booking-heart").cgImage
            } else {
                self.layer.contents = #imageLiteral(resourceName: "empty-heart").cgImage
            }
        }
    }

    init(frame: CGRect = .zero, isSelected: Bool = false) {
        super.init(frame: frame)

        self.isSelected = isSelected

        self.backgroundColor = .clear
        self.clipsToBounds = true
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
