import UIKit

class PaddingLabel: UILabel {
    var topInset: CGFloat = 5.0
    var bottomInset: CGFloat = 5.0
    var leftInset: CGFloat = 7.0
    var rightInset: CGFloat = 7.0

    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(
                top: self.topInset,
                left: self.leftInset,
                bottom: self.bottomInset,
                right: self.rightInset
            )
        }
        set {
            self.topInset = newValue.top
            self.leftInset = newValue.left
            self.rightInset = newValue.right
            self.bottomInset = newValue.bottom
        }
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + self.leftInset + self.rightInset,
            height: size.height + self.topInset + self.bottomInset
        )
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: self.insets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        return textRect
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: self.insets))
    }
}
