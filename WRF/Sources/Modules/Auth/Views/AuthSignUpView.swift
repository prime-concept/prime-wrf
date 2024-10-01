import SnapKit
import UIKit

extension AuthSignUpView {
    struct Appearance {
        let textFieldHeight: CGFloat = 55
        let textFieldsSpacing: CGFloat = 20

        var toolbarTintColor = Palette.shared.iconsPrimary
    }
}

final class AuthSignUpView: UIView {
    let appearance: Appearance

    private lazy var textFieldsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                self.firstNameTextField,
                self.lastNameTextField,
                self.birthDateTextField,
                self.genderTextField,
				self.emailTextField,
                self.phoneTextField
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = self.appearance.textFieldsSpacing
        return stackView
    }()

    private(set) lazy var firstNameTextField = self.makeTextField(title: "Имя")
    private(set) lazy var lastNameTextField: FloatingTextField = {
        let field = self.makeTextField(title: "Фамилия")
        field.title = "Фамилия"
        return field
    }()

    private(set) lazy var birthDateTextField: FloatingTextField = {
        let field = self.makeTextField(title: "Дата рождения")
        field.placeholder = "__.__.____"
        weak var weakSelf = self
        field.onBeginEditingAction = { textField in
            let inputView = PickerWithToolbarView()
            inputView.onSelect = {
                weakSelf?.endEditing(true)
                weakSelf?.birthDate = inputView.datePicker.date
            }
            inputView.onCancel = {
                weakSelf?.endEditing(true)
            }

			inputView.datePicker.maximumDate = Date()
            textField.inputView = inputView.datePicker
            textField.inputAccessoryView = inputView.toolbar
        }
        return field
    }()

    private(set) lazy var genderTextField: FloatingTextField = {
        let field = self.makeTextField(title: "Пол")
        field.placeholder = "Не выбран"
        weak var weakSelf = self
        field.onBeginEditingAction = { textField in
            let inputView = PickerWithToolbarView()
            inputView.onSelect = {
                weakSelf?.endEditing(true)
                weakSelf?.gender = self.temporaryGender
                weakSelf?.genderTextField.text = self.gender?.title
            }
            inputView.onCancel = {
                weakSelf?.endEditing(true)
            }
            inputView.setGenderPicker(dataSource: self, delegate: self)

            textField.inputView = inputView.genderPickerView
            textField.inputAccessoryView = inputView.toolbar
            textField.tintColor = .clear
        }
        let imageView = UIImageView(image: UIImage(named: "arrow-right"))
        field.rightViewMode = .always
        field.rightView = imageView
        return field
    }()

	private(set) lazy var emailTextField = self.makeTextField(title: "E-mail")

    private(set) lazy var phoneTextField: PhoneTextField = {
		let title = "Телефон"
		let textField = PhoneTextField(isAlwaysVisible: true)
		textField.placeholder = title
		textField.title = "\(title)*"
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.snp.makeConstraints { make in
			make.height.equalTo(self.appearance.textFieldHeight)
		}
		textField.keyboardType = .phonePad
		return textField
    }()

    private lazy var confirmationView = AuthConfirmationControlsView()

    private(set) var birthDate: Date? {
        didSet {
            guard let date = self.birthDate else {
                return
            }

            self.birthDateTextField.text = date.formatToShow()
        }
    }

    private(set) var gender: Gender?
    private var temporaryGender: Gender = .male
    private var dataSource: [Gender] = [.male, .female]

    var submitButton: UIControl {
        return self.confirmationView.submitButton
    }

    override var intrinsicContentSize: CGSize {
        let intrinsicSize = self.textFieldsStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: intrinsicSize.height + self.confirmationView.intrinsicContentSize.height
        )
    }

    init(frame: CGRect = .zero, appearance: Appearance = ApplicationAppearance.appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    func showError(message: String) {
        self.phoneTextField.errorMessage = message
    }

    // MARK: - Private API

    @objc
    private func makeTextField(title: String) -> FloatingTextField {
        let textField = FloatingTextField(isAlwaysVisible: true)
        textField.placeholder = title
        textField.title = "\(title)*"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.textFieldHeight)
        }
        return textField
    }
}

extension AuthSignUpView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .clear
    }

    func addSubviews() {
        self.addSubview(self.textFieldsStackView)
        self.addSubview(self.confirmationView)
    }

    func makeConstraints() {
        self.textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        self.textFieldsStackView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        self.confirmationView.translatesAutoresizingMaskIntoConstraints = false
        self.confirmationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.textFieldsStackView.snp.bottom)
        }
    }
}

extension AuthSignUpView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.dataSource.count
    }
}

extension AuthSignUpView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.dataSource[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.temporaryGender = self.dataSource[row]
    }
}
