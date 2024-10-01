import UIKit

enum Localization {
    /// Return appropriate noun form for 1, 4 or 5 number
    static func pluralForm(number: Int, forms: [String]) -> String {
        return number % 10 == 1 && number % 100 != 11
            ? forms[0]
            : (number % 10 >= 2 && number % 10 <= 4 && (number % 100 < 10 || number % 100 >= 20)
                ? forms[1]
                : forms[2]
              )
    }
}
