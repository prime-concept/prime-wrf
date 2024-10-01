import Nuke
import SnapKit
import UIKit

extension RestaurantEventItemView {
    struct Appearance {
        let titleFont = UIFont.wrfFont(ofSize: 18)
        let titleTextColor = UIColor.white
        let titleEditorLineHeight: CGFloat = 21
        let titleInsets = LayoutInsets(left: 10, bottom: 1, right: 10)

        let subtitleFont = UIFont.wrfFont(ofSize: 12, weight: .medium)
        let subtitleTextColor = UIColor.white.withAlphaComponent(0.8)
        let subtitleEditorLineHeight: CGFloat = 14
        let subtitleInsets = LayoutInsets(left: 10, bottom: 5, right: 10)

        let overlayColor = UIColor.black.withAlphaComponent(0.4)
    }
}

final class RestaurantEventItemView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleFont
        label.textColor = self.appearance.subtitleTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lightGray
        view.contentMode = .scaleAspectFill
        return view
    }()

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: self.appearance.titleFont
            )
        }
    }

    var date: String? {
        didSet {
            self.subtitleLabel.attributedText = LineHeightStringMaker.makeString(
                self.date ?? "",
                editorLineHeight: self.appearance.subtitleEditorLineHeight,
                font: self.appearance.subtitleFont
            )
        }
    }

    var imageURL: URL? {
        didSet {
            guard let url = self.imageURL else {
                self.backgroundImageView.image = nil
                return
            }

            Nuke.loadImage(with: url, into: self.backgroundImageView)
        }
    }

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

    func clear() {
        self.titleLabel.attributedText = nil
        self.backgroundImageView.image = nil
    }
}

extension RestaurantEventItemView: ProgrammaticallyDesignable {
    func addSubviews() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.subtitleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.subtitleInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.subtitleInsets.bottom)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
            make.bottom.equalTo(self.subtitleLabel.snp.top).offset(-self.appearance.titleInsets.bottom)
        }
    }
}
