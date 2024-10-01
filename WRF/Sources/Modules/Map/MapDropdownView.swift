import UIKit

// MARK: - appearance

extension MapDropdownButtonView {
    struct Appearance {
        var cornerRadius: CGFloat = 6.0
        var borderWidth: CGFloat = 1.0

        var spacing: CGFloat = 5.0
        var contentInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        var titleColor = Palette.shared.textPrimaryInverse
        var titleFont = UIFont.wrfFont(ofSize: 14.0)

        var imageSize = CGSize(width: 12, height: 12)
        var iconTintColor = Palette.shared.iconsInverseSecondary

        var backgroundColor = Palette.shared.backgroundColorInverse1
        var borderColor = Palette.shared.clear
    }
}

// MARK: - class

final class MapDropdownButtonView: UIView {

    // MARK: - types

    struct ViewModel {
        let title: String
        var image: UIImage? = UIImage(named: "map-arrow-down-icon")
    }

    // MARK: - subviews

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColorThemed = self.appearance.titleColor
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.snp.makeConstraints { $0.size.equalTo(appearance.imageSize) }
        imageView.image = UIImage(named: "map-arrow-down-icon")
        imageView.tintColorThemed = appearance.iconTintColor
        return imageView
    }()

    // MARK: - properites

    private let appearance: Appearance

    // MARK: - life cycle

    init(frame: CGRect = .zero, appearance: Appearance = .init()) {
        self.appearance = appearance
        super.init(frame: frame)

        addSubviews()
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - setups

    func update(with viewModel: ViewModel) {
        imageView.image = viewModel.image
        titleLabel.text = viewModel.title
    }

    private func setupSubviews() {
        backgroundColorThemed = appearance.backgroundColor
        layer.cornerRadius = appearance.cornerRadius
        layer.borderWidth = appearance.borderWidth
        layer.borderColorThemed = appearance.borderColor
    }

    // MARK: - layout

    private func addSubviews() {
        let imageContainer = UIView()
        imageContainer.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
        }

        let stack = UIStackView.horizontal(titleLabel, imageContainer)
        stack.spacing = appearance.spacing

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(appearance.contentInsets)
        }

        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
