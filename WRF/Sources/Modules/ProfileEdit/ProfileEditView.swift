import SnapKit
import UIKit

protocol ProfileEditViewDelegate: AnyObject {
    func profileEditViewDidRequestAvatarChange(_ view: ProfileEditView)
    func profileEditViewShowDisabledDateChangeAlert(_ view: ProfileEditView)
}

extension ProfileEditView {
    struct Appearance {
        let avatarTopOffset: CGFloat = 15
        let avatarSize = CGSize(width: 100, height: 100)

        let stackViewOffset: CGFloat = 20

        let separatorHeight: CGFloat = 1
        let separatorOffset: CGFloat = 15
        let separatorColor = Palette.shared.strokeSecondary

        var toolbarTintColor: UIColor = PGCMain.shared.palette.tintColor
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileEditView: UIView {
    let appearance: Appearance

    weak var delegate: ProfileEditViewDelegate?

    private(set) lazy var avatarView = AvatarView()

    private lazy var avatarTapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(self.avatarClicked(_:))
    )

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private(set) lazy var nameField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Имя*"
        return field
    }()

    private(set) lazy var surnameField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Фамилия"
        return field
    }()

    private(set) lazy var phoneField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Телефон*"
        field.textPattern = .phone
        field.textContentType = .telephoneNumber
        field.isEnabled = false
        return field
    }()

    private(set) lazy var mailField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Email"
        field.textContentType = .emailAddress
        return field
    }()

    private(set) lazy var birthdayField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Дата рождения"
        field.onBeginEditingAction = { [weak self] textField in
            self?.onSelectDateChange(textField: textField)
        }
        return field
    }()

    private(set) lazy var genderField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Пол"
        field.onBeginEditingAction = { [weak self] textField in
            self?.onSelectGenderChange(textField: textField)
        }
        return field
    }()

    private var birthday: Date? {
        didSet {
            guard let date = self.birthday else {
                return
            }

            self.birthdayField.text = date.formatToShow()
        }
    }

    private(set) var gender: Gender?
    private var temporaryGender: Gender = .male
    private var dataSource: [Gender] = [.male, .female]

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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
        let fields = [
            self.nameField,
            self.surnameField,
            self.birthdayField,
            self.genderField,
            self.mailField,
            self.phoneField
        ]
        let maxWidth = fields.map { $0.titleCalculatedWidth }.max() ?? 0
        fields.forEach { $0.titleWidth = maxWidth }
    }

    // MARK: - Public api

    func showClientInfo(_ viewModel: ProfileViewModel) {
        self.avatarView.photo = viewModel.photo
        self.nameField.text = viewModel.name
        self.surnameField.text = viewModel.surname
        self.phoneField.text = viewModel.phone
        self.mailField.text = viewModel.email
        self.birthdayField.text = viewModel.birthday
        self.genderField.text = viewModel.gender?.title
        self.gender = viewModel.gender
    }

    func updateClientPhoto(_ image: UIImage?) {
        self.avatarView.photo = image
    }

    func makeViewModel() -> ProfileViewModel {
        return ProfileViewModel(
            name: self.nameField.text ?? "",
            surname: self.surnameField.text ?? "",
            phone: self.phoneField.unformattedText ?? "",
            email: self.mailField.text ?? "",
            photo: self.avatarView.photo ?? #imageLiteral(resourceName: "user-image"),
            birthday: self.birthday?.formatToBackend() ?? "",
            gender: self.gender
        )
    }

    // MARK: - Private api

    private func addSeparator(offset: CGFloat = 0) {
        let container = UIView()
        self.stackView.addArrangedSubview(container)
        let separator = UIView()
        separator.backgroundColorThemed = self.appearance.separatorColor
        container.addSubview(separator)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(offset)
            make.centerY.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }

    private func onSelectDateChange(textField: UITextField) {
        if let text = self.birthdayField.text, !text.isEmpty {
            textField.inputAccessoryView = nil
            textField.inputView = nil
            textField.resignFirstResponder()
            self.delegate?.profileEditViewShowDisabledDateChangeAlert(self)
            return
        }

        let inputView = PickerWithToolbarView()
        weak var weakSelf = self
        inputView.onSelect = {
            weakSelf?.endEditing(true)
            weakSelf?.birthday = inputView.datePicker.date
        }
        inputView.onCancel = {
            weakSelf?.endEditing(true)
        }

        textField.inputView = inputView.datePicker
        textField.inputAccessoryView = inputView.toolbar
    }

    private func onSelectGenderChange(textField: UITextField) {
        let inputView = PickerWithToolbarView()
        weak var weakSelf = self
        inputView.onSelect = {
            weakSelf?.endEditing(true)
            weakSelf?.gender = self.temporaryGender
            weakSelf?.genderField.text = self.gender?.title
        }
        inputView.onCancel = {
            weakSelf?.endEditing(true)
        }
        inputView.setGenderPicker(dataSource: self, delegate: self)

        textField.inputView = inputView.genderPickerView
        textField.inputAccessoryView = inputView.toolbar
        textField.tintColor = .clear
    }

    @objc
    private func avatarClicked(_ recognizer: UITapGestureRecognizer) {
        self.delegate?.profileEditViewDidRequestAvatarChange(self)
    }
}

extension ProfileEditView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
        self.avatarView.addGestureRecognizer(self.avatarTapGestureRecognizer)
    }

    func addSubviews() {
        self.addSubview(self.avatarView)
        self.addSubview(self.stackView)

        self.addSeparator()
        self.stackView.addArrangedSubview(self.nameField)
        self.addSeparator(offset: self.appearance.separatorOffset)
        self.stackView.addArrangedSubview(self.surnameField)
        self.addSeparator(offset: self.appearance.separatorOffset)
        self.stackView.addArrangedSubview(self.birthdayField)
        self.addSeparator(offset: self.appearance.separatorOffset)
        self.stackView.addArrangedSubview(self.genderField)
        self.addSeparator(offset: self.appearance.separatorOffset)
        self.stackView.addArrangedSubview(self.phoneField)
        self.addSeparator(offset: self.appearance.separatorOffset)
        self.stackView.addArrangedSubview(self.mailField)
        self.addSeparator()
    }

    func makeConstraints() {
        self.avatarView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.avatarTopOffset)
            make.size.equalTo(self.appearance.avatarSize)
            make.centerX.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.bottom).offset(self.appearance.stackViewOffset)
            make.leading.trailing.equalToSuperview()
        }
    }
}

extension ProfileEditView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        self.dataSource.count
    }
}

extension ProfileEditView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.dataSource[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.temporaryGender = self.dataSource[row]
    }
}
