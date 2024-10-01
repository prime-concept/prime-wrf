import SnapKit
import UIKit

extension EmptyDataView {
    struct Appearance: Codable {
        var backgroundColor = Palette.shared.clear
        var titleColor = Palette.shared.textPrimary
        var titleEditorLineHeight: CGFloat = 22

        var iconSize = CGSize(width: 90, height: 90)
        var iconTintColor = Palette.shared.iconsSecondary

        var spacing: CGFloat = 20
    }
}

final class EmptyDataView: UIView {
    let appearance: Appearance

    enum State {
        case loading
        case noData
    }

    var state: State = .loading {
        didSet {
            let isLoading = self.state == .loading
            if isLoading {
                self.indicator.startAnimating()
            } else {
                self.indicator.stopAnimating()
            }
            self.stackView.isHidden = isLoading
            self.indicator.isHidden = !isLoading
        }
    }

    var image: UIImage? {
        didSet {
            guard let image = self.image else {
                self.imageView.image = #imageLiteral(resourceName: "search")
                return
            }
            self.imageView.image = image
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.attributedText = LineHeightStringMaker.makeString(
                self.title ?? "",
                editorLineHeight: self.appearance.titleEditorLineHeight,
                font: UIFont.wrfFont(ofSize: 16),
                alignment: .center
            )
        }
    }

    private lazy var indicator = WineLoaderView()

    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColorThemed = appearance.iconTintColor
        return image
    }()

    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.top.bottom.centerX.equalToSuperview()
            make.size.equalTo(self.appearance.iconSize)
        }
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.wrfFont(ofSize: 16)
        label.textColorThemed = appearance.titleColor
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.imageContainerView, self.titleLabel])
        stack.axis = .vertical
        stack.spacing = self.appearance.spacing
        stack.isHidden = true
        return stack
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

extension EmptyDataView: ProgrammaticallyDesignable {
    public func setupView() {
        self.backgroundColorThemed = self.appearance.backgroundColor
        self.title = "По вашему запросу ничего\nне найдено"
    }

    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.indicator)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        self.imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.imageContainerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.iconSize.height)
        }

        self.indicator.translatesAutoresizingMaskIntoConstraints = false
        self.indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
