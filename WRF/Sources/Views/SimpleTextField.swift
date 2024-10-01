import SnapKit
import UIKit

extension SimpleTextField {
    struct Appearance {
        let fieldLabelTextColor = Palette.shared.textSecondary
        let fieldLabelEditorLineHeight: CGFloat = 17
        let fieldLabelFont = UIFont.wrfFont(ofSize: 15, weight: .light)

        let fieldTextFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var fieldTextColor = Palette.shared.textPrimary
        let fieldTextDisabledColor = Palette.shared.textSecondary

        let separatorHeight: CGFloat = 1
        let separatorColor = Palette.shared.strokeSecondary

        var leadingOffset: CGFloat = 15
        let height: CGFloat = 50

        let spacing: CGFloat = 15
    }
}

final class SimpleTextField: UIView {
    let appearance: Appearance

    private var formatter: InputFormatter?

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.height
        )
    }

    var isEnabled: Bool = true {
        didSet {
            self.fieldText.isEnabled = self.isEnabled
            self.fieldText.textColorThemed = self.isEnabled
                ? self.appearance.fieldTextColor
                : self.appearance.fieldTextDisabledColor
        }
    }

    var onTextUpdate: ((String) -> Void)?

    var title: String? {
        didSet {
            self.fieldLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.fieldLabelEditorLineHeight,
                font: self.appearance.fieldLabelFont
            )
        }
    }

    var text: String? {
        get {
            return self.fieldText.text
        }
        set {
            guard let formatter = self.formatter else {
                self.fieldText.text = newValue
                return
            }
            let result = formatter.format(newValue)
            self.fieldText.text = result
        }
    }

    var placeholder: String? {
        didSet {
            self.fieldText.placeholder = self.placeholder
        }
    }

    var textContentType: UITextContentType? = nil {
        didSet {
            self.fieldText.textContentType = self.textContentType
        }
    }

    var titleWidth: CGFloat = 0 {
        didSet {
            self.titleWidthConstraint?.update(offset: self.titleWidth)
        }
    }

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

    var titleCalculatedWidth: CGFloat {
        return self.fieldLabel.intrinsicContentSize.width
    }

    var onBeginEditingAction: ((UITextField) -> Void)?

    private var titleWidthConstraint: Constraint?

    private lazy var fieldLabel: UILabel = {
        let label = UILabel()
        label.textColorThemed = self.appearance.fieldLabelTextColor
        label.font = self.appearance.fieldLabelFont
        return label
    }()

    private lazy var fieldText: UITextField = {
        let field = UITextField()
        field.textContentType = self.textContentType
        field.font = self.appearance.fieldTextFont
        field.textColorThemed = self.appearance.fieldTextColor
        field.delegate = self
        return field
    }()

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        onTap = { [weak self] in
            self?.fieldText.becomeFirstResponder()
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SimpleTextField: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.fieldLabel)
        self.addSubview(self.fieldText)
    }

    func makeConstraints() {
        self.fieldLabel.translatesAutoresizingMaskIntoConstraints = false
        self.fieldLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.leadingOffset)
            make.centerY.equalToSuperview()
            self.titleWidthConstraint = make.width.equalTo(0).constraint
        }

        self.fieldText.translatesAutoresizingMaskIntoConstraints = false
        self.fieldText.snp.makeConstraints { make in
            make.leading.equalTo(self.fieldLabel.snp.trailing).offset(self.appearance.spacing)
            make.trailing.centerY.equalToSuperview()
        }
    }
}

extension SimpleTextField: UITextFieldDelegate {
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

        self.onTextUpdate?(result.formattedText)
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.onBeginEditingAction?(textField)
    }
}
