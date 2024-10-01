import SnapKit
import UIKit

protocol ProfileFeedbackViewDelegate: AnyObject {
    func viewDidSubmitAppFeedback()
    func viewDidEnterInvalidEmail()
}

extension ProfileFeedbackView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 15)
        var titleColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 22
        let titleOffset = LayoutInsets(top: 20, left: 15, right: 15)

        let descriptionFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let descriptionColor = Palette.shared.textSecondary
        let descriptionEditorLineHeight: CGFloat = 18
        let descriptionOffset = LayoutInsets(top: 10, left: 20, right: 10)

        let separatorHeight: CGFloat = 1
        let separatorColor = Palette.shared.strokeSecondary

        let itemSize = CGSize(width: 54, height: 54)
        let footerSize = CGSize(width: 74, height: 54)

        let sendButtonFont = UIFont.wrfFont(ofSize: 14)
        let sendButtonEditorLineHeight: CGFloat = 16
        let sendButtonOffset = LayoutInsets(left: 25, right: 25)
        let sendButtonOffsets = LayoutInsets(left: 15, bottom: 15, right: 15)
        let sendButtonHeight: CGFloat = 40

        let screenshotsSpacing: CGFloat = 10
        let screenshotsHeight: CGFloat = 104
        let screenshotsInset = UIEdgeInsets(top: 25, left: 20, bottom: 25, right: 20)

        let stackViewTopOffset: CGFloat = 20

        let emailFieldTopOffset: CGFloat = 20
        let textViewTopOffset: CGFloat = 25

        let placeholderFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        let placeholderColor = Palette.shared.textSecondary

        let textInsets = UIEdgeInsets(top: 15, left: 20, bottom: 13, right: 10)
        let leadingOffset: CGFloat = 20
        var backgroundColor = Palette.shared.backgroundColor0
    }
}

final class ProfileFeedbackView: UIView {
    private static let problemTypeTag = 0
    private static let ideaTypeTag = 1

    let appearance: Appearance

    weak var delegate: ProfileFeedbackViewDelegate?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Поделитесь своим мнением о приложении",
            editorLineHeight: self.appearance.titleEditorLineHeight,
            font: self.appearance.titleFont
        )
        return label
    }()

    private lazy var problemTypeView: ProfileFeedbackTypeView = {
        let view = ProfileFeedbackTypeView()
        view.tag = ProfileFeedbackView.problemTypeTag
        view.title = "Сообщить о проблеме"
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.typeClicked(_:)))
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var ideaTypeView: ProfileFeedbackTypeView = {
        let view = ProfileFeedbackTypeView()
        view.tag = ProfileFeedbackView.ideaTypeTag
        view.title = "Идея для улучшения"
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.typeClicked(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.problemTypeView, self.ideaTypeView])
        stack.axis = .vertical
        return stack
    }()

    private lazy var emailField: SimpleTextField = {
        var appearance: SimpleTextField.Appearance = ApplicationAppearance.appearance()
        appearance.leadingOffset = self.appearance.leadingOffset
        let field = SimpleTextField(appearance: appearance)
        field.title = "Email"
        return field
    }()

    private lazy var phoneField: SimpleTextField = {
        var appearance: SimpleTextField.Appearance = ApplicationAppearance.appearance()
        appearance.leadingOffset = self.appearance.leadingOffset
        let field = SimpleTextField(appearance: appearance)
        field.title = "Телефон"
        return field
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.descriptionFont
        label.textColorThemed = self.appearance.descriptionColor
        label.numberOfLines = 0
        label.attributedText = LineHeightStringMaker.makeString(
            "Ответ будет отправлен на вашу почту или по указанному номеру телефона",
            editorLineHeight: self.appearance.descriptionEditorLineHeight,
            font: self.appearance.descriptionFont
        )
        return label
    }()

    private lazy var reviewView: GrowingTextView = {
        var appearance: GrowingTextView.Appearance = ApplicationAppearance.appearance()
        appearance.textInsets = self.appearance.textInsets
        let view = GrowingTextView(appearance: appearance)
        view.font = self.appearance.placeholderFont
        view.placeholder = "Сообщение"
        view.maxTextLength = 300
        return view
    }()

    private lazy var screenshotsCollectionFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = self.appearance.screenshotsSpacing
        return layout
    }()

    private(set) lazy var screenshotsCollection: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.screenshotsCollectionFlowLayout
        )
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellClass: ProfileFeedbackScreenCollectionViewCell.self)
        collectionView.register(
            viewClass: ProfileFeedbackImageAddFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter
        )
        collectionView.contentInset = self.appearance.screenshotsInset
        collectionView.isHidden = true
        return collectionView
    }()

    private lazy var sendButton: ShadowButton = {
        var appearance: ShadowButton.Appearance = ApplicationAppearance.appearance()
        appearance.mainFont = self.appearance.sendButtonFont
        appearance.mainEditorLineHeight = self.appearance.sendButtonEditorLineHeight
        appearance.insets = self.appearance.sendButtonOffset
        let button = ShadowButton(appearance: appearance)
        button.title = "Отправить"
        button.addTarget(self, action: #selector(self.sendButtonClicked), for: .touchUpInside)
        return button
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = ApplicationAppearance.appearance()
    ) {
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
        self.emailField.titleWidth = self.emailField.titleCalculatedWidth
        self.phoneField.titleWidth = self.phoneField.titleCalculatedWidth
        self.descriptionLabel.sizeToFit()
    }

    // MARK: - Public API

    func showClientInfo(_ viewModel: ProfileViewModel) {
        self.emailField.text = viewModel.email
        self.phoneField.text = viewModel.phone
    }

    func updateCollectionView(delegate: UICollectionViewDelegate, dataSource: UICollectionViewDataSource) {
        self.screenshotsCollection.delegate = delegate
        self.screenshotsCollection.dataSource = dataSource
        self.screenshotsCollection.reloadData()
    }

    func makeViewModel(images: [UIImage]) -> ProfileFeedbackViewModel {
        return ProfileFeedbackViewModel(
            type: self.problemTypeView.isSelected ? .problem : .idea,
            email: self.emailField.text ?? "",
            phone: self.phoneField.text ?? "",
            review: self.reviewView.text,
            images: images
        )
    }

    // MARK: - Private API

    @objc
    private func typeClicked(_ gesture: UITapGestureRecognizer) {
        let buttons = [self.problemTypeView, self.ideaTypeView]
        buttons.forEach { $0.isSelected = $0.tag == gesture.view?.tag }
    }

    @objc
    private func sendButtonClicked() {
        guard let email = self.emailField.text,
              !email.isEmpty,
              email.isValidEmail() else {
            delegate?.viewDidEnterInvalidEmail()
            return
        }
        self.delegate?.viewDidSubmitAppFeedback()
    }

    private func makeAndAddSeparator(top equalTo: ConstraintItem, offset: CGFloat) -> UIView {
        let view = UIView()
        self.addSubview(view)
        view.backgroundColorThemed = self.appearance.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.top.equalTo(equalTo).offset(offset)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }
        return view
    }
}

extension ProfileFeedbackView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
        self.problemTypeView.isSelected = true
    }

    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.stackView)
        self.addSubview(self.emailField)
        self.addSubview(self.phoneField)
        self.addSubview(self.descriptionLabel)
        self.addSubview(self.reviewView)
        self.addSubview(self.screenshotsCollection)
        self.addSubview(self.sendButton)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.titleOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleOffset.right)
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.stackViewTopOffset)
            make.leading.trailing.equalToSuperview()
        }

        let emailTopSeparator = self.makeAndAddSeparator(
            top: self.stackView.snp.bottom,
            offset: self.appearance.emailFieldTopOffset
        )

        self.emailField.translatesAutoresizingMaskIntoConstraints = false
        self.emailField.snp.makeConstraints { make in
            make.top.equalTo(emailTopSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        let emailBottomSeparator = self.makeAndAddSeparator(top: self.emailField.snp.bottom, offset: 0)

        self.phoneField.translatesAutoresizingMaskIntoConstraints = false
        self.phoneField.snp.makeConstraints { make in
            make.top.equalTo(emailBottomSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        let phoneBottomSeparator = self.makeAndAddSeparator(top: self.phoneField.snp.bottom, offset: 0)

        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.snp.makeConstraints { make in
            make.top
                .equalTo(phoneBottomSeparator.snp.bottom)
                .offset(self.appearance.descriptionOffset.top)
            make.leading
                .equalToSuperview()
                .offset(self.appearance.descriptionOffset.left)
            make.trailing
                .equalToSuperview()
                .offset(-self.appearance.descriptionOffset.right)
        }

        self.screenshotsCollection.translatesAutoresizingMaskIntoConstraints = false
        self.screenshotsCollection.snp.makeConstraints { make in
            make.bottom.equalTo(self.sendButton.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.screenshotsHeight)
        }

        let screenshotsTopSeparator = self.makeAndAddSeparator(top: self.screenshotsCollection.snp.top, offset: 0)

        let messageTopSeparator = self.makeAndAddSeparator(
            top: self.descriptionLabel.snp.bottom,
            offset: self.appearance.textViewTopOffset
        )

        self.reviewView.translatesAutoresizingMaskIntoConstraints = false
        self.reviewView.snp.makeConstraints { make in
            make.top.equalTo(messageTopSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(screenshotsTopSeparator.snp.top)
        }

        self.sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.bottom
                    .equalTo(self.safeAreaLayoutGuide.snp.bottom)
                    .offset(-self.appearance.sendButtonOffsets.bottom)
            } else {
                make.bottom
                    .equalToSuperview()
                    .offset(-self.appearance.sendButtonOffsets.bottom)
            }
            make.leading.equalToSuperview().offset(self.appearance.sendButtonOffsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.sendButtonOffsets.right)
            make.height.equalTo(self.appearance.sendButtonHeight)
        }
    }
}
