import Foundation

enum FormatterPattern {
    case phone
    case text(format: TextFormat)

    enum TextFormat: String {
        case bankCardNumber = "#### #### #### ####"
        case bankCardDate = "##/##"

        var patternString: String {
            return self.rawValue
        }
    }
}

extension FormatterPattern {
    var formatter: InputFormatter? {
        switch self {
        case .phone:
            return PhoneNumberFormatter()
        case .text(let format):
            return TextInputFormatter(textPattern: format.patternString)
        }
    }
}
