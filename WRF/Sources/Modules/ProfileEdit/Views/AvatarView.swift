import SnapKit
import UIKit

extension AvatarView {
    struct Appearance {
        let changeLabelTextColor = UIColor.white
        let changeLabelEditorLineHeight: CGFloat = 14
        let changeLabelFont = UIFont.wrfFont(ofSize: 12)
        let changeLabelTopOffset: CGFloat = 5

        let cornerRadius: CGFloat = 50

        let bottomContainerHeight: CGFloat = 30
        let bottomContainerBackgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
}

final class AvatarView: UIView {
    let appearance: Appearance

    var photo: UIImage? {
        get {
            return self.avatarImageView.image
        }
        set {
            guard let newImage = newValue else {
                self.avatarImageView.image = #imageLiteral(resourceName: "user-image")
                return
            }
            self.avatarImageView.image = newImage
        }
    }

    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "user-image"))
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.changeLabelTextColor
        label.font = self.appearance.changeLabelFont
        label.attributedText = LineHeightStringMaker.makeString(
                "изменить",
                editorLineHeight: self.appearance.changeLabelEditorLineHeight,
                font: self.appearance.changeLabelFont
        )
        return label
    }()

    private lazy var bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.bottomContainerBackgroundColor
        return view
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
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

extension AvatarView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.bottomContainer)
        self.bottomContainer.addSubview(self.changeLabel)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        self.bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.appearance.bottomContainerHeight)
        }

        self.changeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.changeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.changeLabelTopOffset)
            make.centerX.equalToSuperview()
        }
    }
}
