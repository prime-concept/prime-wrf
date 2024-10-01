import UIKit

extension Notification.Name {
    static let paletteDidChange = Notification.Name("paletteDidChange")
}

private var isBeingUpdated = false

var paletteIsBeingUpdated: Bool {
    isBeingUpdated
}

class Palette: Codable {
    static let shared = Palette()
    
    private(set) var accentСolor = 0x949494.themedColor("accentСolor")
    private(set) var black = 0x000000.themedColor("black")
    private(set) var white = 0xFFFFFF.themedColor("white")
    private(set) var gray = 0x949494.themedColor("gray")
    private(set) var danger = 0xFF4F4F.themedColor("danger")

    private(set) var backgroundColor0 = 0xFFFFFF.themedColor("backgroundColor0")
    private(set) var backgroundColor1 = 0xFFFFFF.themedColor("backgroundColor1")
    private(set) var backgroundColor2 = 0xFFFFFF.themedColor("backgroundColor2")
    private(set) var backgroundColorInverse1 = 0xFFFFFF.themedColor("backgroundColorInverse1")
    private(set) var backgroundColorInverse2 = 0xFFFFFF.themedColor("backgroundColorInverse2")
    private(set) var backgroundColorBrand = 0xFFFFFF.themedColor("backgroundColorBrand")
    
    
    private(set) var textPrimary = 0x000000.themedColor("textPrimary")
    private(set) var textPrimaryInverse = 0xFFFFFF.themedColor("textPrimaryInverse")
    private(set) var textSecondary = 0x949494.themedColor("textSecondary")
    private(set) var textSecondaryInverse = 0x949494.themedColor("textSecondaryInverse")

    private(set) var strokeStrong = 0x000000.themedColor("strokeStrong")
    private(set) var strokePrimary = 0xE5E5E5.themedColor("strokePrimary")
    private(set) var strokeSecondary = 0xE5E5E5.themedColor("strokeSecondary")
    
    private(set) var iconsBrand = 0x000000.themedColor("iconsBrand")
    private(set) var iconsSecondary = 0xCCCBCB.themedColor("iconsSecondary")
    private(set) var iconsInverseSecondary = 0x1E1F26.themedColor("iconsInverseSecondary")
    private(set) var iconsPrimary = 0x000000.themedColor("iconsPrimary")
    
    private(set) var gradient0 = 0xFFFFFF.themedColor("gradient0")
    private(set) var gradient1 = 0xFFFFFF.themedColor("gradient1")
    
    private(set) var cardGradient0 = 0xF2F2F2.themedColor("cardGradient0")
    private(set) var cardGradient1 = 0xEAEAEA.themedColor("cardGradient1")
    
    private(set) var buttonAccent = 0x000000.themedColor("buttonAccent")
    private(set) var clear = ThemedColor(UIColor.clear, id: "clear")
}

extension Palette {
    func updateFrom(file: String, ofType type: String) {
        if let path = Bundle.main.path(forResource: file, ofType: type),
           let json = try? String(contentsOfFile: path),
           let data = json.data(using: .utf8) {
            self.update(from: data)
        }
    }

    func update(from data: Data) {
        isBeingUpdated = true

        defer {
            isBeingUpdated = false
        }

        guard let instance = try? JSONDecoder().decode(Palette.self, from: data)
        else {
            return
        }

        let selfMirror = Mirror(reflecting: self)
        let newMirror = Mirror(reflecting: instance)

        newMirror.children.forEach { newChild in
            let selfChild = selfMirror.children.first { $0.label == newChild.label }
            if
                let color = selfChild?.value as? ThemedColor,
                let newColor = newChild.value as? ThemedColor
            {
                color.rawValue = newColor.rawValue
                return
            }
            if
                let font = selfChild?.value as? ThemedFont,
                let newFont = newChild.value as? ThemedFont
            {
                font.rawValue = newFont.rawValue
            }
        }
    }

    func themedColor(by id: String?) -> ThemedColor? {
        self.allThemedColors.first{ $0.id == id }
    }

    func themedFont(by id: String?) -> ThemedFont? {
        self.allThemedFonts.first{ $0.id == id }
    }

    var allThemedColors: [ThemedColor] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap{ $0.value as? ThemedColor }
    }

    var allThemedFonts: [ThemedFont] {
        let mirror = Mirror(reflecting: self)
        let fonts = mirror.children.compactMap{ $0.value as? ThemedFont }
        return fonts
    }

    func randomize() {
        self.allThemedColors.forEach {
            if $0.rawValue.isEqual(UIColor.clear) {
                return
            }
            $0.rawValue = Int.random(in: 0...0xFFFFFF).asUIColor
        }

        self.allThemedFonts.forEach { font in
            font.rawValue = UIFont.random(font.rawValue.pointSize) ?? font.rawValue
        }

        NotificationCenter.default.post(.paletteDidChange)
    }

    func restore() {
        self.black.rawValue = 0x000000.asUIColor
        self.clear.rawValue = UIColor.clear
        self.white.rawValue = 0xFFFFFF.asUIColor
        self.gray.rawValue = 0x949494.asUIColor
        self.danger.rawValue = 0xFF4F4F.asUIColor

        self.accentСolor.rawValue = 0x949494.asUIColor
        self.backgroundColor0.rawValue = 0xFFFFFF.asUIColor
        self.backgroundColor1.rawValue = 0xFFFFFF.asUIColor
        self.backgroundColor2.rawValue = 0xFFFFFF.asUIColor
        self.backgroundColorInverse1.rawValue = 0x000000.asUIColor
        self.textPrimary.rawValue = 0x000000.asUIColor
        self.textSecondary.rawValue = 0x949494.asUIColor
        self.strokeStrong.rawValue = 0x000000.asUIColor
        self.strokeSecondary.rawValue = 0xE5E5E5.asUIColor
        self.iconsBrand.rawValue = 0x000000.asUIColor
        self.iconsSecondary.rawValue = 0xCCCBCB.asUIColor
        self.gradient0.rawValue = 0xFFFFFF.asUIColor
        self.gradient1.rawValue = 0xFFFFFF.asUIColor
        self.buttonAccent.rawValue = 0x000000.asUIColor
        self.backgroundColorBrand.rawValue = 0xFFFFFF.asUIColor
        self.cardGradient0.rawValue = 0xF2F2F2.asUIColor
        self.cardGradient1.rawValue = 0xEAEAEA.asUIColor
        self.iconsPrimary.rawValue = 0x000000.asUIColor
        
        NotificationCenter.default.post(.paletteDidChange)
    }
}

extension UIFont {
    static func random(_ size: CGFloat) -> UIFont? {
        guard let family = UIFont.familyNames.randomElement() else {
            return nil
        }
        guard let fontName = UIFont.fontNames(forFamilyName: family).randomElement() else {
            return nil
        }

        return UIFont(name: fontName, size: size)
    }
}
