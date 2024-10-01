import SkyFloatingLabelTextField
import SnapKit
import UIKit

extension FloatingTextField {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 12)
        let titleColor = Palette.shared.textSecondary

        let placeholderFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        let placeholderColor = Palette.shared.textSecondary

        let textColor = Palette.shared.textPrimary
        let textFont = UIFont.wrfFont(ofSize: 15, weight: .light)

        let lineColor = Palette.shared.strokeSecondary
        let lineHeight: CGFloat = 1
    }
}

final class FloatingTextField: SkyFloatingLabelTextField {
    let appearance: Appearance

    private var formatter: InputFormatter?

    var textPattern: FormatterPattern? {
        didSet {
            guard let pattern = self.textPattern else {
                return
            }
            self.formatter = pattern.formatter
        }
    }

    var unformattedText: String? {
        guard let formatter = self.formatter else {
            return self.text
        }
        return formatter.unformat(self.text)
    }

    var onBeginEditingAction: ((UITextField) -> Void)?

    init(frame: CGRect = .zero, isAlwaysVisible: Bool = false, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()

        if isAlwaysVisible {
            self.setTitleVisible(true)
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FloatingTextField: ProgrammaticallyDesignable {
    func setupView() {
        self.delegate = self

        self.titleFormatter = { $0 }
        self.titleFont = self.appearance.titleFont
        self.titleColor = self.appearance.titleColor.rawValue
        self.selectedTitleColor = self.appearance.titleColor.rawValue

        self.textColor = self.appearance.textColor.rawValue
        self.font = self.appearance.textFont

        self.placeholderFont = self.appearance.placeholderFont
        self.placeholderColor = self.appearance.placeholderColor.rawValue

        self.lineColor = self.appearance.lineColor.rawValue
        self.selectedLineColor = self.appearance.lineColor.rawValue
        self.lineHeight = self.appearance.lineHeight
        self.selectedLineHeight = self.appearance.lineHeight
    }
}

extension FloatingTextField: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let formatter = self.formatter else {
            return true
        }
        let result = formatter.formatInput(
            currentText: textField.text ?? "",
            range: range,
            replacementString: string
        )
        textField.text = result.formattedText
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.onBeginEditingAction?(textField)
    }
}
