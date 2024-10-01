import Nuke
import SnapKit
import UIKit

extension VideoEventItemView {
    struct Appearance {
        var cornerRadius: CGFloat = 15

        let nameLabelFont = UIFont.wrfFont(ofSize: 20)
        let nameLabelTextColor = UIColor.white
        let nameLabelEditorLineHeight: CGFloat = 22

        let authorLabelFont = UIFont.wrfFont(ofSize: 13)
        let authorLabelTextColor = UIColor.white.withAlphaComponent(0.8)
        let authorLabelEditorLineHeight: CGFloat = 16

        let nameLabelTopOffset: CGFloat = 3
        let stackViewSpacing: CGFloat = 8

        let commonInsets = LayoutInsets(top: 15, left: 15, bottom: 15, right: 15)
        let overlayColor = UIColor.black.withAlphaComponent(0.3)

        let shareButtonInsets = LayoutInsets(left: 15, bottom: 5, right: 5)
        let shareButtonSize = CGSize(width: 44, height: 44)

        let liveLabelFont = UIFont.wrfFont(ofSize: 16)
        let liveLabelTextColor = UIColor.white
        let liveLabelEditorLineHeight: CGFloat = 19
        let liveIconSize = CGSize(width: 12, height: 12)
        let liveSpacing: CGFloat = 8
    }
}

final class VideoEventItemView: UIView {
    let appearance: Appearance

    var onShareButtonClick: (() -> Void)?

    var title: String? {
        didSet {
            self.nameLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.nameLabelEditorLineHeight,
                font: self.appearance.nameLabelFont,
                lineBreakMode: .byTruncatingTail
            )
        }
    }

    var imageURL: URL? {
        didSet {
            guard let imageURL = self.imageURL else {
                return
            }
            self.imageView.loadImage(from: imageURL)
        }
    }

    var isLive: Bool = true {
        didSet {
            self.liveView.isHidden = !self.isLive
        }
    }

    var author: String? {
        didSet {
            guard let author = self.author else {
                self.authorLabel.attributedText = nil
                self.authorLabel.isHidden = true
                return
            }
            self.authorLabel.attributedText = LineHeightStringMaker.makeString(
                author,
                editorLineHeight: self.appearance.authorLabelEditorLineHeight,
                font: self.appearance.authorLabelFont,
                lineBreakMode: .byTruncatingTail
            )
        }
    }

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.authorLabelFont
        label.textColor = self.appearance.authorLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "share-video"), for: .normal)
        button.addTarget(self, action: #selector(self.shareButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var liveIconWrapper = UIView()
    private lazy var liveIcon = UIImageView(image: #imageLiteral(resourceName: "live-icon"))
    private lazy var liveLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.liveLabelFont
        label.textColor = self.appearance.liveLabelTextColor
        label.attributedText = LineHeightStringMaker.makeString(
            "Live",
            editorLineHeight: self.appearance.liveLabelEditorLineHeight,
            font: self.appearance.liveLabelFont
        )
        return label
    }()

    private lazy var liveView: UIView = {
        self.liveIconWrapper.addSubview(self.liveIcon)

        let view = UIStackView(arrangedSubviews: [self.liveIconWrapper, self.liveLabel])
        view.spacing = self.appearance.liveSpacing
        view.axis = .horizontal
        return view
    }()

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

    // MARK: - Public API

    func clear() {
        self.imageView.image = nil
        self.nameLabel.attributedText = nil
    }

    // MARK: - Private

    @objc
    private func shareButtonClicked() {
        self.onShareButtonClick?()
    }
}

extension VideoEventItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.authorLabel)
        self.addSubview(self.shareButton)
        self.addSubview(self.liveView)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.shareButton.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.shareButtonSize)
            make.bottom.equalTo(-self.appearance.shareButtonInsets.bottom)
            make.trailing.equalTo(-self.appearance.shareButtonInsets.right)
        }

        self.authorLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.commonInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.commonInsets.bottom)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-self.appearance.commonInsets.right)
        }

        self.liveView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.commonInsets.left)
            make.top.equalToSuperview().offset(self.appearance.commonInsets.top)
        }

        self.liveIcon.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.liveIconSize)
            make.center.equalToSuperview()
        }

        self.liveIconWrapper.snp.makeConstraints { make in
            make.width.equalTo(self.appearance.liveIconSize.width)
        }

        self.nameLabel.snp.makeConstraints { make in
            make.bottom
                .equalTo(self.authorLabel.snp.top)
                .offset(-self.appearance.nameLabelTopOffset)
            make.leading.equalToSuperview().offset(self.appearance.commonInsets.left)
            make.trailing.equalTo(self.shareButton.snp.leading).offset(-self.appearance.commonInsets.right)
        }
    }
}
