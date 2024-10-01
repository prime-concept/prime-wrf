import UIKit

extension UserView {
    struct Appearance: Codable {
        var nameLabelEditorLineHeight: CGFloat = 17
        var nameLabelColor = Palette.shared.textPrimary
        var cardTypeLabelTextColor = Palette.shared.textPrimary
        var cardTypeLabelBorderColor = Palette.shared.clear
        var cardTypeLabelBorderWidth: CGFloat = 1
        var cardTypeLabelBackgroundColor = Palette.shared.backgroundColorBrand
        var cardTypeLabelInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        var cardTypeLabelCornerRadius: CGFloat = 10
        var cardTypeLabelTopOffset: CGFloat = 5

        var userImageSize = CGSize(width: 50, height: 50)

        var containerViewLeftOffset: CGFloat = 10
    }
}

final class UserView: UIView {
    let appearance: Appearance

    var fullName: String? {
        didSet {
            self.nameLabel.attributedText = LineHeightStringMaker.makeString(
                self.fullName ?? "",
                editorLineHeight: self.appearance.nameLabelEditorLineHeight,
                font: UIFont.wrfFont(ofSize: 15),
                lineBreakMode: .byTruncatingTail
            )
        }
    }

    var gradeName: String? {
        didSet {
            self.cardTypeLabel.text = self.gradeName
        }
    }

    var userImage: UIImage? {
        didSet {
            guard let image = self.userImage else {
                return
            }
            self.userImageView.image = image
        }
    }

    private lazy var userImageView: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "user-image"))
        image.contentMode = .scaleAspectFill
        return image
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.wrfFont(ofSize: 15)
        label.textColorThemed = self.appearance.nameLabelColor
        return label
    }()

    private lazy var cardTypeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.insets = self.appearance.cardTypeLabelInsets
        label.textColor = self.appearance.cardTypeLabelTextColor.rawValue
        label.backgroundColor = self.appearance.cardTypeLabelBackgroundColor.rawValue
        label.font = UIFont.wrfFont(ofSize: 12)
        return label
    }()

    private lazy var containerView = UIView()

    init(frame: CGRect = .zero, appearance: Appearance = Theme.shared.userViewAppearance) {
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
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
    }
}

extension UserView: ProgrammaticallyDesignable {
    func setupView() {
        self.cardTypeLabel.layer.masksToBounds = true
        self.userImageView.layer.masksToBounds = true
        self.cardTypeLabel.layer.cornerRadius = self.appearance.cardTypeLabelCornerRadius
        self.cardTypeLabel.layer.borderWidth = self.appearance.cardTypeLabelBorderWidth
        self.cardTypeLabel.layer.borderColorThemed = self.appearance.cardTypeLabelBorderColor
    }

    func addSubviews() {
        self.addSubview(self.userImageView)
        self.addSubview(self.containerView)
        self.containerView.addSubview(self.nameLabel)
        self.containerView.addSubview(self.cardTypeLabel)
    }

    func makeConstraints() {
        self.userImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.userImageSize)
        }

        self.containerView.snp.makeConstraints { make in
            make.leading.equalTo(self.userImageView.snp.trailing).offset(self.appearance.containerViewLeftOffset)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        self.nameLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.cardTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.cardTypeLabelTopOffset)
            make.bottom.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
