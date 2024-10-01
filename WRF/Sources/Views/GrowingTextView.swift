import SnapKit
import UIKit

extension GrowingTextView {
    struct Appearance {
        var textInsets = UIEdgeInsets(top: 13, left: 10, bottom: 13, right: 10)
        var minHeight: CGFloat = 125
        var textColor = Palette.shared.textPrimary
        var placeholderColor = Palette.shared.textSecondary
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class GrowingTextView: UITextView {
    let appearance: Appearance

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColorThemed = self.appearance.placeholderColor
        label.font = self.font
        return label
    }()

    var maxTextLength: Int?

    // swiftlint:disable:next implicitly_unwrapped_optional
    override var text: String! {
        didSet {
            self.placeholderLabel.isHidden = !self.text.isEmpty
        }
    }

    var placeholder: String? {
        get {
            return self.placeholderLabel.text
        }
        set {
            self.placeholderLabel.text = newValue
        }
    }

    override var font: UIFont? {
        didSet {
            self.placeholderLabel.font = self.font
        }
    }

    init(
        frame: CGRect = .zero,
        textContainer: NSTextContainer? = nil,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame, textContainer: textContainer)
        self.registerForNotifications()
        self.setupView()

        textColorThemed = self.appearance.textColor
        backgroundColorThemed = self.appearance.backgroundColor
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let preferredSize = self.placeholderLabel.sizeThatFits(
            CGSize(width: self.textContainer.size.width, height: CGFloat.greatestFiniteMagnitude)
        )
        self.placeholderLabel.frame = CGRect(
            origin: self.placeholderLabel.frame.origin,
            size: preferredSize
        )
    }

    private func setupView() {
        // To make paddings like in UILabel
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = self.appearance.textInsets

        self.isScrollEnabled = false

        self.addSubview(self.placeholderLabel)
        self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.textInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.textInsets.left)
        }

        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(self.appearance.minHeight)
        }
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textViewDidEndEditing),
            name: UITextView.textDidEndEditingNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textViewDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
    }

    @objc
    private func textViewDidChange() {
        if let maxTextLength = self.maxTextLength {
            self.text = String(self.text.prefix(maxTextLength))
        } else {
            self.placeholderLabel.isHidden = !self.text.isEmpty
        }
    }

    @objc
    private func textViewDidEndEditing() {
        self.text = self.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
