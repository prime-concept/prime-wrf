import SnapKit
import UIKit

extension ProfileAboutSocialsView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 12, weight: .light)
        let titleColor = UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)
        let titleEditorLineHeight: CGFloat = 14

        let versionFont = UIFont.wrfFont(ofSize: 15)
        let versionColor = UIColor.black
        let versionEditorLineHeight: CGFloat = 17

        let stackSpacing: CGFloat = 5
        let iconSize = CGSize(width: 48, height: 48)
    }
}

final class ProfileAboutSocialsView: UIView {
    let appearance: Appearance

    private lazy var facebookIcon: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "contacts-facebook"))
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var instagramIcon: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "contacts-instagram"))
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var linkIcon: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "contacts-link"))
        image.contentMode = .scaleAspectFit
        return image
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews: [
                self.facebookIcon,
                self.instagramIcon,
                self.linkIcon
            ]
        )
        stack.axis = .horizontal
        return stack
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

extension ProfileAboutSocialsView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        [self.facebookIcon, self.instagramIcon, self.linkIcon].forEach {
            $0.snp.makeConstraints { make in
                make.size.equalTo(self.appearance.iconSize)
            }
        }
    }
}
