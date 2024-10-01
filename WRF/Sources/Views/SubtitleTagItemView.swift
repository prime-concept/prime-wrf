import Nuke
import SnapKit
import UIKit

extension SubtitleTagItemView {
    struct Appearance {
        let cornerRadius: CGFloat = 8
        let dimColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)

        let titleFont = UIFont.wrfFont(ofSize: 14)
        let titleTextColor = UIColor.white
        let titleLineHeight: CGFloat = 16
        let titleLabelInsets = LayoutInsets(top: 4, left: 25, right: 25)

        let subtitleFont = UIFont.wrfFont(ofSize: 10, weight: .medium)
        let subtitleTextColor = UIColor.white.withAlphaComponent(0.8)
        let subtitleLineHeight: CGFloat = 11
        let subtitleLabelInsets = LayoutInsets(top: 0, bottom: 3)

        let selectionIndicatorColor = UIColor.white
        let selectionIndicatorSize = CGSize(width: 20, height: 1)
        let selectionIndicatorCornerRadius: CGFloat = 1
        let selectionIndicatorInsets = LayoutInsets(bottom: 2)
    }
}

final class SubtitleTagItemView: UIView {
    let appearance: Appearance

    private lazy var selectionIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.selectionIndicatorColor
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.selectionIndicatorCornerRadius
        view.isHidden = true
        return view
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.dimColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleFont
        label.textColor = self.appearance.subtitleTextColor
        return label
    }()

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.titleLineHeight,
                font: self.appearance.titleFont,
                alignment: .center
            )
        }
    }

    var subtitle: String? {
        didSet {
            self.subtitleLabel.attributedText = LineHeightStringMaker.makeString(
                self.subtitle ?? "",
                editorLineHeight: self.appearance.subtitleLineHeight,
                font: self.appearance.subtitleFont
            )
        }
    }

    var imageURL: URL? {
        didSet {
            guard let url = self.imageURL else {
                self.imageView.image = nil
                return
            }

            Nuke.loadImage(with: url, into: self.imageView)
        }
    }

    var isSelected = false {
        didSet {
            self.selectionIndicatorView.isHidden = !self.isSelected
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
        self.imageView.image = nil
        self.subtitleLabel.attributedText = nil
        self.titleLabel.attributedText = nil
        self.isSelected = false
    }
}

extension SubtitleTagItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.dimView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.selectionIndicatorView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.dimView.translatesAutoresizingMaskIntoConstraints = false
        self.dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
        }
        self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.subtitleLabelInsets.top)
            make.bottom.equalToSuperview().offset(-self.appearance.subtitleLabelInsets.bottom)
            make.centerX.equalToSuperview()
        }
        self.subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        self.subtitleLabel.setContentHuggingPriority(.required, for: .horizontal)

        self.selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.selectionIndicatorView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.selectionIndicatorSize)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.selectionIndicatorInsets.bottom)
        }
    }
}
