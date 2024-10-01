import AnyFormatKit
import Foundation

final class TextInputFormatter: InputFormatter {
    private let defaultFormatter: DefaultTextInputFormatter

    init(textPattern: String) {
        self.defaultFormatter = DefaultTextInputFormatter(textPattern: textPattern)
    }

    func format(_ unformattedText: String?) -> String? {
        return self.defaultFormatter.format(unformattedText)
    }

    func unformat(_ formattedText: String?) -> String? {
        return self.defaultFormatter.unformat(formattedText)
    }

    func formatInput(currentText: String, range: NSRange, replacementString text: String) -> FormattedResult {
        let result = self.defaultFormatter.formatInput(currentText: currentText, range: range, replacementString: text)
        return FormattedResult(formattedText: result.formattedText, caretBeginOffset: result.caretBeginOffset)
    }
}
