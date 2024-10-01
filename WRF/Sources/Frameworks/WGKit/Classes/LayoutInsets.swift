import UIKit

/// `LayoutInsets` works like `UIEdgeInsets` but throw error in runtime when some components are undefined
public struct LayoutInsets {
    private let topInset: CGFloat?
    private let leftInset: CGFloat?
    private let rightInset: CGFloat?
    private let bottomInset: CGFloat?

    public var top: CGFloat {
        guard let value = self.topInset else {
            fatalError("Top inset is undefined")
        }
        return value
    }

    public var left: CGFloat {
        guard let value = self.leftInset else {
            fatalError("Left inset is undefined")
        }
        return value
    }

    public var right: CGFloat {
        guard let value = self.rightInset else {
            fatalError("Right inset is undefined")
        }
        return value
    }

    public var bottom: CGFloat {
        guard let value = self.bottomInset else {
            fatalError("Bottom inset is undefined")
        }
        return value
    }

    public init(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        self.topInset = top
        self.leftInset = left
        self.rightInset = right
        self.bottomInset = bottom
    }

    public init(insets: UIEdgeInsets) {
        self.topInset = insets.top
        self.leftInset = insets.left
        self.rightInset = insets.right
        self.bottomInset = insets.bottom
    }
}
