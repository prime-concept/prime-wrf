import UIKit

extension UIView {
    func dropShadow(
        offset: CGSize,
        radius: CGFloat,
        color: UIColor,
        opacity: CGFloat
    ) {
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = Float(opacity)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.masksToBounds = false
    }

    func resetShadow() {
        self.layer.shadowOpacity = 0
    }

    func dropShadowThemed(
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 6,
        color: ThemedColor = Palette.shared.black,
        opacity: CGFloat = 0.2
    ) {
        dropShadow(
            offset: offset, 
            radius: radius,
            color: color.rawValue,
            opacity: opacity
        )
        
        layer.shadowColorThemed = color
    }
}
