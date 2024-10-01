import UIKit

extension PGCResources.Images {
    
    enum About { }
    enum HomeScreen { }
    
    private static func image(namespace: String, assetName: String) -> UIImage {
        UIImage(named: "images/\(namespace)/\(assetName)", in: Bundle(for: PGCMain.self), compatibleWith: nil)!
    }
    
    private static func brandedImage(name: String) -> UIImage {
        PGCMain.shared.resourceProvider.image(name: name)
    }
    
}

// MARK: - About

extension PGCResources.Images.About {
    
    static let header = PGCResources.Images.brandedImage(name: "branded/about/header")
    
}

// MARK: - Home Screen

extension PGCResources.Images.HomeScreen {
    
    static let logo = PGCResources.Images.brandedImage(name: "branded/home_screen/logo")
    static let profileIcon = image(assetName: "profile_icon")
    static let notificationsIcon = image(assetName: "notifications_icon")

    private static func image(assetName: String) -> UIImage {
        PGCResources.Images.image(namespace: "home_screen", assetName: assetName)
    }
    
}
