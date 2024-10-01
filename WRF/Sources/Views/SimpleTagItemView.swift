import SnapKit
import UIKit

extension SimpleTagItemView {
    struct Appearance {
        let cornerRadius: CGFloat = 8
        let overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        let titleFont = UIFont.wrfFont(ofSize: 14)
        let titleTextColor = UIColor.white
        let titleLineHeight: CGFloat = 16
        let titleLabelInsets = LayoutInsets(top: 10, left: 20, bottom: 9, right: 20)

        let selectionIndicatorColor = UIColor.white
        let selectionIndicatorSize = CGSize(width: 20, height: 1)
        let selectionIndicatorCornerRadius: CGFloat = 1
        let selectionIndicatorInsets = LayoutInsets(bottom: 2)
    }
}

final class SimpleTagItemView: UIView {
    let appearance: Appearance

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

    var imageURL: URL? {
        didSet {
            guard let imageURL = self.imageURL else {
                return
            }
            self.imageView.loadImage(from: imageURL)
        }
    }

    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }

    var isSelected = false {
        didSet {
            self.selectionIndicatorView.isHidden = !self.isSelected
        }
    }

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
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        return label
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

extension SimpleTagItemView: ProgrammaticallyDesignable {
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.selectionIndicatorView)
    }

    public func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.titleLabelInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.titleLabelInsets.bottom)
        }
        self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
        self.titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        self.selectionIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.selectionIndicatorView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.selectionIndicatorSize)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.selectionIndicatorInsets.bottom)
        }
    }
}
