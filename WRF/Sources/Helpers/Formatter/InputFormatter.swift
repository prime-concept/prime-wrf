import Foundation

protocol InputFormatter {
    func format(_ unformattedText: String?) -> String?
    func unformat(_ formattedText: String?) -> String?
    func formatInput(currentText: String, range: NSRange, replacementString text: String) -> FormattedResult
}
