import UIKit

enum CustomFontName: String {
    case regular = "Ubuntu-Regular"
    case bold = "Ubuntu-Bold"
    case italic = "Ubuntu-Italic"
    case medium = "Ubuntu-Medium"
    case light = "Ubuntu-Light"
}

// swiftlint:disable force_unwrapping
extension UIFont {
    class func wrfFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case UIFont.Weight.ultraLight, UIFont.Weight.light, UIFont.Weight.thin:
            return UIFont(name: CustomFontName.light.rawValue, size: size)!
        case UIFont.Weight.semibold, UIFont.Weight.medium:
            return UIFont(name: CustomFontName.medium.rawValue, size: size)!
        case UIFont.Weight.bold, UIFont.Weight.heavy, UIFont.Weight.black:
            return UIFont(name: CustomFontName.bold.rawValue, size: size)!
        default:
            return UIFont(name: CustomFontName.regular.rawValue, size: size)!
        }
    }

    class func wrfFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: CustomFontName.regular.rawValue, size: size)!
    }

    @objc
    class func boldWRFFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: CustomFontName.bold.rawValue, size: size)!
    }

    @objc
    class func italicWRFFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: CustomFontName.italic.rawValue, size: size)!
    }
}
// swiftlint:enable force_unwrapping
