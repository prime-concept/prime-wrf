import SnapKit
import UIKit

extension ProfileFeedbackTypeView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 15, weight: .light)
        var titleColor = Palette.shared.textPrimary
        let titleEditorLineHeight: CGFloat = 17

        let imageSize = CGSize(width: 20, height: 20)
        let leadingOffset: CGFloat = 15

        let itemHeight: CGFloat = 51
    }
}

final class ProfileFeedbackTypeView: UIView {
    let appearance: Appearance

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.itemHeight)
    }

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont
            )
        }
    }

    var isSelected: Bool = false {
        didSet {
            self.imageView.image = self.isSelected ? #imageLiteral(resourceName: "selection-on") : #imageLiteral(resourceName: "selection-off")
        }
    }
//#imageLiteral(resourceName: "selection-off")
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "selection-off")
        return image
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
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
}

extension ProfileFeedbackTypeView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.leadingOffset)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.imageSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.leadingOffset)
            make.centerY.trailing.equalToSuperview()
        }
    }
}
