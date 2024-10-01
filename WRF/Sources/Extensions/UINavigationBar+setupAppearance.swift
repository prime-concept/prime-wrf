import UIKit

extension UINavigationBar {
    class func setupAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            if PGCMain.shared.featureFlags.appSetup.needsTransparentNavigationBar {
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = .clear
            } else {
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColorThemed = Palette.shared.backgroundColor0
            }

            navigationBarAppearance.standardAppearance = appearance
            navigationBarAppearance.scrollEdgeAppearance = navigationBarAppearance.standardAppearance
        }

        navigationBarAppearance.tintColorThemed = Palette.shared.textPrimary
        navigationBarAppearance.titleTextAttributes = [
            .font: UIFont.wrfFont(ofSize: 17),
            .foregroundColorThemed: Palette.shared.textPrimary
        ]

        navigationBarAppearance.isTranslucent = PGCMain.shared.featureFlags.appSetup.needsTransparentNavigationBar
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default)
        navigationBarAppearance.shadowImage = UIImage()

        let barButtonAppearance = UIBarButtonItem.appearance(
            whenContainedInInstancesOf: [UINavigationBar.self]
        )
        barButtonAppearance.setTitleTextAttributes(
            [.font: UIFont.wrfFont(ofSize: 17)],
            for: .normal
        )
        barButtonAppearance.setTitleTextAttributes(
            [.font: UIFont.wrfFont(ofSize: 17)],
            for: .highlighted
        )
    }
}

extension UINavigationBarAppearance {
    var backgroundColorThemed: ThemedColor? {
        get {
            let result: ThemedColor? =
            ObjcAssociatedProperty.get(from: self, for: &ThemeObjcKeys.backgroundColor)

            return result
        }
        set {
            self.backgroundColor = newValue?.rawValue

            ObjcAssociatedProperty.set(
                newValue,
                to: self,
                for: &ThemeObjcKeys.backgroundColor
            )

            let token = newValue?.subscribe { [weak self] color in
                self?.backgroundColor = color
            }

            guard let token = token else {
                ObjcAssociatedProperty.remove(&ThemeObjcKeys.backgroundColorDeallocator, from: self)
                return
            }

            let deallocator = Deallocator { [weak newValue] in
                newValue?.unsubscribe(token)
            }

            ObjcAssociatedProperty.set(
                deallocator,
                to: self,
                for: &ThemeObjcKeys.backgroundColorDeallocator
            )
        }
    }
}
