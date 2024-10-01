import AnyFormatKit
import SnapKit
import UIKit

protocol ProfilePaymentDetailViewDelegate: AnyObject {
    func addPayment(number: String, date: String)
    func savePayment(number: String, date: String)
    func removePayment()

    func isEditingCardNumber(newText: String?)
}

extension ProfilePaymentDetailView {
    struct Appearance {
        let separatorSize = CGSize(width: 1, height: 1)
        let separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)

        let titleFont = UIFont.wrfFont(ofSize: 18)
        let titleColor = UIColor.black
        let titleEditorLineHeight: CGFloat = 18
        let titleTopOffset: CGFloat = 29

        let buttonFont = UIFont.wrfFont(ofSize: 14)
        let buttonEditorLineHeight: CGFloat = 16
        let buttonInsets = LayoutInsets(left: 25, right: 25)

        let descriptionFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let descriptionColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let descriptionEditorLineHeight: CGFloat = 18
        let descriptionOffset = LayoutInsets(top: 15, left: 15, right: 15)

        let cardImageSize = CGSize(width: 22, height: 14)
        let cardImageRightOffset: CGFloat = 20

        let separatorHeight: CGFloat = 1
        let separatorTopOffset: CGFloat = 11
        let separatorLeftOffset: CGFloat = 15

        let stackContainerOffset = LayoutInsets(top: 40, bottom: 20)
        let stackContainerHeight: CGFloat = 40
        let stackSpacing: CGFloat = 10
    }
}

final class ProfilePaymentDetailView: UIView {
    let appearance: Appearance

    var cardNumber: String? {
        didSet {
            self.cardField.text = self.cardNumber
        }
    }

    var cardDate: String? {
        didSet {
            self.cardDateField.text = self.cardDate
        }
    }

    var cardImage: UIImage? {
        didSet {
            self.cardImageView.image = self.cardImage
        }
    }

    weak var delegate: ProfilePaymentDetailViewDelegate?

    private var isEditMode: Bool = false

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleColor
        label.attributedText = LineHeightStringMaker.makeString(
            self.isEditMode ? "Редактировать карту" : "Добавление карты",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        return label
    }()

    private lazy var cardField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Номер карты"
        field.textPattern = .text(format: .bankCardNumber)
        field.onTextUpdate = { [weak self] text in
            self?.delegate?.isEditingCardNumber(newText: text)
        }
        return field
    }()

    private lazy var cardDateField: SimpleTextField = {
        let field = SimpleTextField()
        field.title = "Срок действия"
        field.textPattern = .text(format: .bankCardDate)
        return field
    }()

    private lazy var cardImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.descriptionFont
        label.textColor = self.appearance.descriptionColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Карта зашифрована в KeyChain и доступна только на этом устройстве",
            editorLineHeight: self.appearance.descriptionEditorLineHeight,
            font: self.appearance.descriptionFont
        )
        return label
    }()

    private lazy var buttonAppearance = ShadowButton.Appearance(
        mainFont: self.appearance.buttonFont,
        mainEditorLineHeight: self.appearance.buttonEditorLineHeight,
        insets: self.appearance.buttonInsets
    )

    private lazy var addButton: ShadowButton = {
        let button = ShadowButton(appearance: self.buttonAppearance)
        button.title = "Добавить карту"
        button.addTarget(self, action: #selector(self.addClicked), for: .touchUpInside)
        return button
    }()

    private lazy var saveButton: ShadowButton = {
        let button = ShadowButton(appearance: self.buttonAppearance)
        button.title = "Сохранить карту"
        button.addTarget(self, action: #selector(self.saveClicked), for: .touchUpInside)
        return button
    }()

    private lazy var removeButton: ShadowButton = {
        let button = ShadowButton(appearance: self.buttonAppearance)
        button.title = "Удалить"
        button.addTarget(self, action: #selector(self.removeClicked), for: .touchUpInside)
        return button
    }()

    private lazy var stackContainerView = UIView()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: self.isEditMode ? [self.removeButton, self.saveButton] : [self.addButton]
        )
        stack.axis = .horizontal
        stack.spacing = self.appearance.stackSpacing
        return stack
    }()

    init(
        frame: CGRect = .zero,
        isEditMode: Bool,
        appearance: Appearance = Appearance()
    ) {
        self.isEditMode = isEditMode
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
        // update title width
        let fields = [self.cardField, self.cardDateField]
        let maxWidth = fields.map { $0.titleCalculatedWidth }.max() ?? 0
        fields.forEach { $0.titleWidth = maxWidth }
    }

    // MARK: - Private API

    @objc
    private func addClicked() {
        guard let number = self.cardField.text,
              !number.isEmpty else {
            return
        }
        guard let date = self.cardDateField.text,
              !date.isEmpty else {
            return
        }
        self.delegate?.addPayment(number: number, date: date)
    }

    @objc
    private func saveClicked() {
        guard let number = self.cardField.text,
              !number.isEmpty else {
            return
        }
        guard let date = self.cardDateField.text,
              !date.isEmpty else {
            return
        }
        self.delegate?.savePayment(number: number, date: date)
    }

    @objc
    private func removeClicked() {
        self.delegate?.removePayment()
    }

    private func makeSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
        }
        return view
    }
}

extension ProfilePaymentDetailView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.cardField)
        self.cardField.addSubview(self.cardImageView)
        self.addSubview(self.cardDateField)
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.stackContainerView)
        self.stackContainerView.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top
                    .equalTo(self.safeAreaLayoutGuide.snp.top)
                    .offset(self.appearance.titleTopOffset)
            } else {
                make.top
                    .equalToSuperview()
                    .offset(self.appearance.titleTopOffset)
            }
            make.centerX.equalToSuperview()
        }

        let separator = self.makeSeparator()
        self.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.separatorTopOffset)
            make.leading.trailing.equalToSuperview()
        }

        self.cardField.translatesAutoresizingMaskIntoConstraints = false
        self.cardField.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.cardImageView.translatesAutoresizingMaskIntoConstraints = false
        self.cardImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.cardImageSize)
            make.trailing.equalToSuperview().offset(-self.appearance.cardImageRightOffset)
            make.centerY.equalToSuperview()
        }

        let secondSeparator = self.makeSeparator()
        self.addSubview(secondSeparator)
        secondSeparator.translatesAutoresizingMaskIntoConstraints = false
        secondSeparator.snp.makeConstraints { make in
            make.top.equalTo(self.cardField.snp.bottom)
            make.leading.equalToSuperview().offset(self.appearance.separatorLeftOffset)
            make.trailing.equalToSuperview()
        }

        self.cardDateField.translatesAutoresizingMaskIntoConstraints = false
        self.cardDateField.snp.makeConstraints { make in
            make.top.equalTo(secondSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        let thirdSeparator = self.makeSeparator()
        self.addSubview(thirdSeparator)
        thirdSeparator.translatesAutoresizingMaskIntoConstraints = false
        thirdSeparator.snp.makeConstraints { make in
            make.top.equalTo(self.cardDateField.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(thirdSeparator.snp.bottom).offset(self.appearance.descriptionOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.descriptionOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.descriptionOffset.right)
        }

        self.stackContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.stackContainerView.snp.makeConstraints { make in
            make.top
                .equalTo(self.descriptionLabel.snp.bottom)
                .offset(self.appearance.stackContainerOffset.top)
            make.height.equalTo(self.appearance.stackContainerHeight)
            make.leading.trailing.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
        }
    }
}
