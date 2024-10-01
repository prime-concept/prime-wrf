import UIKit
import PhoneNumberKit
//swiftlint:disable all

struct CountryCode {
    var countryName: String
    var countryCode: UInt64?
    var flagImageName: String
    var mask: String?
    var isSelected: Bool = false
}

extension CountryCode {
    static func makeCodes() -> [CountryCode] {
        var result: [CountryCode] = []
        let phoneKit = PhoneNumberKit()
        var countryCodes = phoneKit.allCountries()
        countryCodes.removeAll { $0 == "001" || countryName(countryCode: $0) == "Tristan da Cunha" }
        for countryCode in countryCodes {
            let one = CountryCode(
                countryName: Self.countryName(countryCode: countryCode),
                countryCode: phoneKit.countryCode(for: countryCode),
                flagImageName: countryCode,
                mask: phoneKit.getFormattedExampleNumber(forCountry: countryCode)
            )
            result.append(one)
        }
        result.sort { $0.countryName < $1.countryName }
        let index = result.firstIndex { $0.countryName == countryName(countryCode: "RU") } ?? 0
        result.swapAt(0, index)
        return result
    }
    
    static var defaultCountryCode: CountryCode {
        return makeCodes().first { $0.countryName == countryName(countryCode: "RU") } ?? CountryCode(countryName: "RU", flagImageName: "")
    }
    
    var countryCodeDisplayable: String {
        return  "+\(countryCode ?? 0)"
    }
    
    var flagImage: UIImage {
        return UIImage(named: flagImageName) ?? UIImage()
    }
    
    var maskDisplayable: String {
        guard var validMask = mask,
              let validCode = countryCode
        else { return "_" }
        let count = "\(validCode)".count
        validMask = validMask.replacingOccurrences(of: "+", with: "")
        validMask = validMask.replacingOccurrences(of: "[0-9]", with: "_", options: .regularExpression)
        validMask = validMask.replacingOccurrences(of: ".", with: "-")
        validMask.removeSubrange(validMask.startIndex...validMask.index(validMask.startIndex, offsetBy: count))
        return validMask
    }
    
    static func countryName(countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return countryCode
        }
    }
}
