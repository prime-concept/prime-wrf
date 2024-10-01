import SkyFloatingLabelTextField
import SnapKit
import UIKit
import PhoneNumberKit

extension PhoneTextField {
	struct Appearance {
		let titleFont = UIFont.wrfFont(ofSize: 12)
        let titleColor = Palette.shared.textSecondary

		let placeholderFont = UIFont.wrfFont(ofSize: 15, weight: .light)
		let placeholderColor = Palette.shared.textSecondary

        let textColor = Palette.shared.textPrimary
		let textFont = UIFont.wrfFont(ofSize: 15, weight: .light)

        let lineColor = Palette.shared.strokeSecondary
		let lineHeight: CGFloat = 1
        var iconColor = Palette.shared.iconsBrand
	}
}

final class PhoneTextField: SkyFloatingLabelTextField {
	let appearance: Appearance

	private var countryCodeViewController: UIViewController? = nil
	private var currentCountryCode: CountryCode {
		willSet {
			self.updateFormat(
				oldCountryCode: currentCountryCode,
				newCountryCode: newValue
			)
		}
		didSet {
			self.updateFormat(
				oldCountryCode: currentCountryCode,
				newCountryCode: currentCountryCode
			)
		}
	}

	private(set) lazy var phoneNumberTextField = PhoneNumberTextField()

	private lazy var flagImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = self.currentCountryCode.flagImage
		imageView.contentMode = .scaleToFill
		imageView.layer.cornerRadius = 2
		imageView.layer.borderWidth = 1 / UIScreen.main.scale
		imageView.layer.borderColor = UIColor(hex: 0x949494).cgColor
		imageView.clipsToBounds = true
		imageView.make(.size, .equal, [24, 16])
		return imageView
	}()

	private lazy var countrySelectionView = UIStackView { (stack: UIStackView) in
		stack.axis = .horizontal
		stack.spacing = 8
		stack.alignment = .center

		stack.addArrangedSubview(self.flagImageView)
		stack.addArrangedSubview(UIImageView { (imageView: UIImageView) in
            imageView.tintColorThemed = self.appearance.iconColor
			imageView.image = UIImage(named: "icon-arrow-down")
			imageView.make(.size, .equal, [10, 6])
		})
		stack.addArrangedSpacer(growable: 0)

		stack.make(.size, .equal, [55, 16])

		stack.onTap = { [weak self] in
			self?.showCountryPicker()
		}
	}

	var unformattedText: String? {
		self.text?.replacing(regex: "[^\\d]", with: "")
	}

	var onBeginEditingAction: ((UITextField) -> Void)?

	init(frame: CGRect = .zero, isAlwaysVisible: Bool = false, appearance: Appearance = Appearance()) {
		self.appearance = appearance
		self.currentCountryCode = CountryCode.defaultCountryCode

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

	override func layoutSubviews() {
		super.layoutSubviews()

		self.subviews
			.first { NSStringFromClass(type(of: $0)) == "UITextFieldLabel" }
			.flatMap {
				self.inset($0, dx: 55)
			}

		self.inset(self.lineView, dx: 55)
		self.countrySelectionView.frame.origin.y = 25
	}

	private func inset(_ view: UIView, dx: CGFloat) {
		view.frame.origin.x = dx
		view.frame.size.width = self.bounds.width - dx
	}
}

extension PhoneTextField: ProgrammaticallyDesignable {
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

		self.leftView = self.countrySelectionView
		self.leftViewMode = .always

		self.currentCountryCode = CountryCode.defaultCountryCode
	}
}

extension PhoneTextField: UITextFieldDelegate {
	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString: String
	) -> Bool {
		var text = textField.text ?? ""

		let code = self.currentCountryCode.countryCode
		let codeString = code != nil ? "\(code!)" : ""
		let plusPrefixedCodeString = "+\(codeString)"

		defer {
			if text.first != "+" {
				text = "+\(text)"
			}

			if text == plusPrefixedCodeString {
				text += " "
			}

			self.text = text
			self.phoneNumberTextField.text = text
		}

		if range.location < plusPrefixedCodeString.count, text.count >= plusPrefixedCodeString.count {
			return false
		}

		text = (text as NSString).replacingCharacters(in: range, with: replacementString)
		text = self.phoneNumberTextField.partialFormatter.formatPartial(text)
		
		return false
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.onBeginEditingAction?(textField)
	}
}

extension PhoneTextField: CountryCodeSelectionDelegate {
	func select(countryCode: CountryCode) {
		self.currentCountryCode = countryCode
		self.countryCodeViewController?.dismiss(animated: true)
	}

	func showCountryPicker() {
		let assembly = CountryCodesAssembly(countryCode: self.currentCountryCode, delegate: self)
		let countryCodesController = assembly.makeModule()
		self.countryCodeViewController = countryCodesController

		self.topMostController()?.present(countryCodesController, animated: true)
	}

	private func updateFormat(oldCountryCode: CountryCode, newCountryCode: CountryCode) {
		let oldCodeString = oldCountryCode.countryCode != nil ? "\(oldCountryCode.countryCode!)" : ""
		let newCodeString = newCountryCode.countryCode != nil ? "\(newCountryCode.countryCode!)" : ""

		let unformattedText = self.unformattedText ?? ""
		let newText = unformattedText
			.replacing(regex: "^(\(oldCodeString))?", with: "\(newCodeString)")

		self.setPhoneNumberAndApplyFormat(newText)

		self.flagImageView.image = newCountryCode.flagImage
	}

	private func setPhoneNumberAndApplyFormat(_ newText: String) {
		var newText = newText
		if !newText.hasPrefix("+") {
			newText = "+" + newText
		}
		newText = self.phoneNumberTextField.partialFormatter.formatPartial(newText)

		self.text = ""
		self.phoneNumberTextField.text = ""

		_ = self.textField(
			self,
			shouldChangeCharactersIn: NSRange(location: 0, length: 0),
			replacementString: newText
		)
	}
}
