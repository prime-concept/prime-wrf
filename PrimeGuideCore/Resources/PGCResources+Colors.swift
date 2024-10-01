import UIKit

extension PGCResources.Colors {
    
    enum Icon { }
    
    private static func color(namespace: String, assetName: String) -> UIColor {
        UIColor(named: "colors/\(namespace)/\(assetName)", in: Bundle(for: PGCMain.self), compatibleWith: nil)!
    }
    
    private static func brandedColor(name: String) -> UIColor {
        PGCMain.shared.resourceProvider.color(name: name)
    }
    
}

// MARK: - Icon

extension PGCResources.Colors.Icon {
    
    static let primary = color(assetName: "primary")
    
    private static func color(assetName: String) -> UIColor {
        PGCResources.Colors.color(namespace: "icons", assetName: assetName)
    }
    
}
