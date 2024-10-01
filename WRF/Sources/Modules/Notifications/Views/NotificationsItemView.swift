import UIKit

extension NotificationsItemView {
    struct Appearance {
        let notificationIconSize = CGSize(width: 18, height: 18)
        let notificationContainerSize = CGSize(width: 36, height: 36)

        let messageFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var messageColor = UIColor.black
        let messageTextEditorLineHeight: CGFloat = 17
        let messageInsets = LayoutInsets(top: 10, left: 15, bottom: 5, right: 15)

        let timeFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let timeColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let timeTextEditorLineHeight: CGFloat = 14
        let timeInsets = LayoutInsets(left: 8, bottom: 8, right: 15)

        let insets = LayoutInsets(top: 5, bottom: 5)
        let spacing: CGFloat = 4

        let imageContainerWidth: CGFloat = 41

        let notificationIconBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        let borderWidth: CGFloat = 1
        let borderRadius: CGFloat = 20

        let bubbleViewInsets = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 10)
    }
}

final class NotificationsItemView: UIView {
    let appearance: Appearance

    static func itemHeight(for message: String, time: String, width: CGFloat) -> CGFloat {
        let item = Self()
        let appearance = item.appearance

        let width = width
            - appearance.imageContainerWidth
            - appearance.spacing
            - appearance.messageInsets.left
            - appearance.messageInsets.right

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = appearance.messageTextEditorLineHeight
            - appearance.messageFont.lineHeight

        let messageHeight = message.boundingRect(
            with: CGSize(width: width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: appearance.messageFont, .paragraphStyle: paragraphStyle],
            context: nil
        ).height

        let timeHeight = time.boundingRect(
            with: CGSize(width: width, height: CGFloat.infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: appearance.timeFont],
            context: nil
        ).height

        let height = appearance.insets.top
            + appearance.messageInsets.top
            + messageHeight
            + appearance.messageInsets.bottom
            + timeHeight
            + appearance.timeInsets.bottom
            + appearance.insets.bottom

        return height
    }

    var message: String? {
        didSet {
            self.messageLabel.attributedText = LineHeightStringMaker.makeString(
                self.message ?? "",
                editorLineHeight: self.appearance.messageTextEditorLineHeight,
                font: self.appearance.messageFont
            )
        }
    }

    var messageTime: String? {
        didSet {
            self.timeLabel.attributedText = LineHeightStringMaker.makeString(
                self.messageTime ?? "",
                editorLineHeight: self.appearance.timeTextEditorLineHeight,
                font: self.appearance.timeFont,
                alignment: .right
            )
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.insets.top
            + self.appearance.messageInsets.top
            + self.messageLabel.intrinsicContentSize.height
            + self.appearance.messageInsets.bottom
            + self.timeLabel.intrinsicContentSize.height
            + self.appearance.timeInsets.bottom
            + self.appearance.insets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    private lazy var notificationIcon: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.notificationIconBackgroundColor
        return view
    }()

    private lazy var notificationImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "map-button-notification"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var notificationIconContainer = UIView()

    private lazy var bubbleView: UIImageView = {
        let image = UIImage(named: "message-border")?.resizableImage(
            withCapInsets: self.appearance.bubbleViewInsets,
            resizingMode: .stretch
        )
        let view = UIImageView(image: image)
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = self.appearance.messageFont
        label.textColor = self.appearance.messageColor
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.timeFont
        label.textColor = self.appearance.timeColor
        return label
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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
        self.notificationIcon.layer.cornerRadius = self.appearance.notificationContainerSize.height / 2
    }
}

extension NotificationsItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.notificationIconContainer)
        self.notificationIcon.addSubview(self.notificationImageView)
        self.notificationIconContainer.addSubview(self.notificationIcon)
        self.addSubview(self.bubbleView)
        self.bubbleView.addSubview(self.messageLabel)
        self.bubbleView.addSubview(self.timeLabel)
    }

    func makeConstraints() {
        self.notificationIconContainer.translatesAutoresizingMaskIntoConstraints = false
        self.notificationIconContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalToSuperview()
            make.width.equalTo(self.appearance.imageContainerWidth)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }

        self.notificationIcon.translatesAutoresizingMaskIntoConstraints = false
        self.notificationIcon.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.notificationContainerSize)
            make.bottom.centerX.equalToSuperview()
        }

        self.notificationImageView.translatesAutoresizingMaskIntoConstraints = false
        self.notificationImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.notificationIconSize)
            make.center.equalToSuperview()
        }

        self.bubbleView.translatesAutoresizingMaskIntoConstraints = false
        self.bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalTo(self.notificationIconContainer.snp.trailing).offset(self.appearance.spacing)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }

        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.messageInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.messageInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.messageInsets.right)
            make.bottom.greaterThanOrEqualTo(self.timeLabel.snp.top).offset(-self.appearance.messageInsets.bottom)
        }

        self.timeLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.timeInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.timeInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.timeInsets.bottom)
        }
    }
}
