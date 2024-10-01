import Foundation

struct FeatureFlags {
    struct TabBar {
        static let shouldUseStaticTitle = true
        static let shouldUseUnselectedColor = true
    }

    struct Loyalty {
        static let shouldUseCardImage = false
        static let showsPersonifiedFeatures = false
    }

    struct Profile {
        static let scanButtonHidden = true
    }

    struct Map {
        static let showVISALogo = false
    }
}
