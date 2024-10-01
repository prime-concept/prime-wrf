import SnapKit
import UIKit

extension ProfilePaymentsItemView {
    struct Appearance {
        let cardCodeFont = UIFont.wrfFont(ofSize: 15)
        let cardCodeEditorLineHeight: CGFloat = 17
        let cardCodeColor = UIColor.black
        let cardCodeOffset = LayoutInsets(top: 13, left: 15, right: 5)

        let cardDateFont = UIFont.wrfFont(ofSize: 15)
        let cardDateEditorLineHeight: CGFloat = 17
        let cardDateColor = UIColor.black
        let cardDateOffset = LayoutInsets(left: 15, bottom: 15)

        let iconSize = CGSize(width: 65, height: 53)

        let alignmentInsets = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 5)
    }
}

final class ProfilePaymentsItemView: UIView {
    let appearance: Appearance

    var code: String? {
        didSet {
            self.cardCodeLabel.attributedText = LineHeightStringMaker.makeString(
                self.code ?? "",
                editorLineHeight: self.appearance.cardCodeEditorLineHeight,
                font: self.appearance.cardCodeFont
            )
        }
    }

    var date: String? {
        didSet {
            self.cardDateLabel.attributedText = LineHeightStringMaker.makeString(
                self.date ?? "",
                editorLineHeight: self.appearance.cardDateEditorLineHeight,
                font: self.appearance.cardDateFont
            )
        }
    }

    var image: UIImage? {
        didSet {
            self.cardIcon.image = self.image
        }
    }

    private lazy var shadowView: ShadowBackgroundView = {
        let appearance = ShadowBackgroundView.Appearance(
            alignmentInsets: self.appearance.alignmentInsets
        )
        return ShadowBackgroundView(appearance: appearance)
    }()

    private lazy var cardCodeLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.cardCodeFont
        label.textColor = self.appearance.cardCodeColor
        return label
    }()

    private lazy var cardDateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.cardDateFont
        label.textColor = self.appearance.cardDateColor
        return label
    }()

    private lazy var cardIcon: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
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
}

extension ProfilePaymentsItemView: ProgrammaticallyDesignable {
    public func addSubviews() {
        self.addSubview(self.shadowView)
        self.addSubview(self.cardCodeLabel)
        self.addSubview(self.cardDateLabel)
        self.addSubview(self.cardIcon)
    }

    public func makeConstraints() {
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.cardCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardCodeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.cardCodeOffset.top)
            make.leading.equalToSuperview().offset(self.appearance.cardCodeOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.cardCodeOffset.right)
        }

        self.cardDateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.cardDateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.cardDateOffset.left)
            make.bottom.equalToSuperview().offset(-self.appearance.cardDateOffset.bottom)
        }

        self.cardIcon.translatesAutoresizingMaskIntoConstraints = false
        self.cardIcon.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.size.equalTo(self.appearance.iconSize)
        }
    }
}
