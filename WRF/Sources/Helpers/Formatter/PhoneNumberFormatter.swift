import AnyFormatKit
import Foundation
import libPhoneNumber_iOS

final class PhoneNumberFormatter: InputFormatter {
    private let phoneNumberUtil: NBPhoneNumberUtil
    private var phoneNumber: NBPhoneNumber?

    init() {
        self.phoneNumberUtil = NBPhoneNumberUtil.sharedInstance()
    }

    func format(_ unformattedText: String?) -> String? {
        guard var number = unformattedText,
              !number.isEmpty else {
            return nil
        }
        if !number.starts(with: "+") {
            number = "+\(number)"
        }
        let region = self.calculateRegion(from: number)
        self.phoneNumber = try? self.phoneNumberUtil.parse(number, defaultRegion: region)
        guard let formattedNumber = try? self.phoneNumberUtil.format(
            self.phoneNumber,
            numberFormat: .INTERNATIONAL
        ) else {
            let formatter = NBAsYouTypeFormatter(regionCode: region)
            return formatter?.inputString(number)
        }
        return formattedNumber
    }

    func unformat(_ formatted: String?) -> String? {
        guard let phoneNumber = self.phoneNumber else {
            return nil
        }
        return "\(phoneNumber.countryCode.stringValue)\(phoneNumber.nationalNumber.stringValue)"
    }

    func formatInput(currentText: String, range: NSRange, replacementString text: String) -> FormattedResult {
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        let formattedText = self.format(newText) ?? ""

        return FormattedResult(
            formattedText: formattedText,
            caretBeginOffset: range.location
        )
    }

    private func calculateRegion(from number: String) -> String {
        var region: String?
        let regionCode = self.phoneNumberUtil.extractCountryCode(
            number,
            nationalNumber: nil
        )
        region = self.phoneNumberUtil.getRegionCode(forCountryCode: regionCode)
        return region ?? self.phoneNumberUtil.countryCodeByCarrier()
    }
}
