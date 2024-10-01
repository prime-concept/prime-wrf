import SnapKit
import UIKit

extension RestaurantLikesView {
    struct Appearance {
        let avatarSize = CGSize(width: 40, height: 40)
        let avatarOverlapWidth: CGFloat = 12
        let borderWidth: CGFloat = 3
        let borderColor = UIColor.white

        let font = UIFont.wrfFont(ofSize: 13)
        let highlightFont = UIFont.wrfFont(ofSize: 13, weight: .medium)
        var textColor = UIColor.black
        let editorLineHeight: CGFloat = 16
        let insets = LayoutInsets(top: 20, left: 15, bottom: 0, right: 15)
        let spacing: CGFloat = 10
    }
}

final class RestaurantLikesView: UIView {
    private static let maxAvatarsCount = 3
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.appearance.textColor
        return label
    }()

    private lazy var avatarsContainerView = UIView()

    var displayingAvatars: [UIImage] = [] {
        didSet {
            self.updateDisplayingAvatars()
        }
    }

    var displayingInfo: (name: String, totalCount: Int)? {
        didSet {
            self.updateDisplayingLabel()
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.insets.top + self.appearance.avatarSize.height + self.appearance.insets.bottom
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

    // MARK: - Private API

    private func updateDisplayingLabel() {
        guard let info = self.displayingInfo else {
            return
        }

        let totalCount = max(0, info.totalCount - 1)
        let text = LineHeightStringMaker.makeString(
            "Оценили \(info.name)" + (totalCount > 0 ? " и ещё \(totalCount)" : ""),
            editorLineHeight: self.appearance.editorLineHeight,
            font: self.appearance.font
        )

        let rangeName = NSRange(location: 8, length: info.name.count)
        text.addAttribute(.font, value: self.appearance.highlightFont, range: rangeName)

        if totalCount > 0 {
            let rangeTotalCount = NSRange(location: rangeName.upperBound + 3, length: 4 + "\(totalCount)".count)
            text.addAttribute(.font, value: self.appearance.highlightFont, range: rangeTotalCount)
        }

        self.textLabel.attributedText = text
    }

    private func updateDisplayingAvatars() {
        let avatarImages = Array(self.displayingAvatars.prefix(RestaurantLikesView.maxAvatarsCount))

        for subview in self.avatarsContainerView.subviews {
            subview.removeFromSuperview()
        }

        for (index, avatar) in avatarImages.enumerated() {
            let imageView = UIImageView(image: avatar)

            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = self.appearance.avatarSize.width / 2
            imageView.layer.borderColor = self.appearance.borderColor.cgColor
            imageView.layer.borderWidth = self.appearance.borderWidth

            self.avatarsContainerView.insertSubview(imageView, at: 0)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.avatarSize)
                make.centerY.equalToSuperview()
                make.leading
                    .equalToSuperview()
                    .offset(CGFloat(index) * (self.appearance.avatarSize.width - self.appearance.avatarOverlapWidth))
            }
        }

        self.avatarsContainerView.snp.updateConstraints { make in
            let width = CGFloat(avatarImages.count) * self.appearance.avatarSize.width
                - CGFloat(avatarImages.count - 1) * self.appearance.avatarOverlapWidth
            make.width.equalTo(width)
        }
    }
}

extension RestaurantLikesView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.avatarsContainerView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.avatarsContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarsContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.width.equalTo(0)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarsContainerView.snp.trailing).offset(self.appearance.spacing)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalTo(self.avatarsContainerView.snp.centerY)
        }
    }
}
