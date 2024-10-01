import SnapKit
import UIKit

extension MyCardInfoTypeView {
    struct Appearance {
        let imageSize = CGSize(width: 49, height: 49)
        let shadowHeight: CGFloat = 32

        let shadowViewOffset = LayoutInsets(left: 36, right: 16)

        var typeLabelTextColor = Palette.shared.textPrimary
        let typeLabelFont = UIFont.wrfFont(ofSize: 12)
        let typeLabelEditorLineHeight: CGFloat = 14
        let typeLabelOffset = LayoutInsets(left: 20, right: 20)
    }
}

final class MyCardInfoTypeView: UIView {
    let appearance: Appearance

    var gradeName: String? {
        didSet {
            self.typeLabel.attributedText = LineHeightStringMaker.makeString(
                self.gradeName ?? "",
                editorLineHeight: self.appearance.typeLabelEditorLineHeight,
                font: self.appearance.typeLabelFont
            )
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

    private lazy var shadowView = ShadowBackgroundView()

    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.textColorThemed = self.appearance.typeLabelTextColor
        label.font = self.appearance.typeLabelFont
        label.lineBreakMode = .byTruncatingTail
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
    }
}

extension MyCardInfoTypeView: ProgrammaticallyDesignable {
    func setupView() {
        self.userImageView.layer.masksToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.shadowView)
        self.shadowView.addSubview(self.typeLabel)
        self.addSubview(self.userImageView)
    }

    func makeConstraints() {
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.shadowHeight)
            make.leading.equalToSuperview().offset(self.appearance.shadowViewOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.shadowViewOffset.right)
            make.centerY.equalToSuperview()
        }

        self.typeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.typeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.typeLabelOffset.left)
            make.trailing.equalToSuperview().offset(-self.appearance.typeLabelOffset.right)
            make.centerY.equalToSuperview()
        }

        self.userImageView.translatesAutoresizingMaskIntoConstraints = false
        self.userImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.imageSize)
        }
    }
}
