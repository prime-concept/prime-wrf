import UIKit
import SnapKit

class HomeScreenNavbarItemView: UIView {
    struct Appearance {
        let badgeFont = UIFont.wrfFont(ofSize: 10, weight: .bold)

        let badgeTextColor = Palette.shared.white
        let badgeBackgroundColor = Palette.shared.danger

        let badgeLabelInsets = UIEdgeInsets(top: 0, left: 2, bottom: 1, right: 2)

        let badgeContainerOffset = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 5)
        let badgeContainerCornerRadius: CGFloat = 6

        let imageTintColor = Palette.shared.iconsPrimary

        let imageSize = CGSize(width: 20, height: 20)

        let selfSize = CGSize(width: 44, height: 44)
    }

    struct ViewModel {
        let image: UIImage
        let badgeText: String?
    }

    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColorThemed = appearance.imageTintColor
        return imageView
    }()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.textColorThemed = appearance.badgeTextColor
        label.font = appearance.badgeFont
        label.textAlignment = .center
        return label
    }()

    private lazy var badgeLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColorThemed = appearance.badgeBackgroundColor
        view.layer.cornerRadius = appearance.badgeContainerCornerRadius
        view.isHidden = true

        return view
    }()

    required init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance

        super.init(frame: frame)

        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: ViewModel) {
        imageView.image = viewModel.image
        badgeLabel.text = viewModel.badgeText
        badgeLabelContainer.isHidden = viewModel.badgeText?.isEmpty ?? true
    }

    private func setupSubviews() {
        addSubview(imageView)

        badgeLabelContainer.addSubview(badgeLabel)
        imageView.addSubview(badgeLabelContainer)

        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(appearance.imageSize)
        }

        badgeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(appearance.badgeLabelInsets)
        }

        badgeLabelContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-appearance.badgeContainerOffset.top)
            make.trailing.equalToSuperview().offset(appearance.badgeContainerOffset.right)
            make.width.greaterThanOrEqualTo(badgeLabelContainer.snp.height)
        }

        self.snp.makeConstraints { make in
            make.size.equalTo(appearance.selfSize)
        }
    }
}

extension HomeScreenNavbarItemView {
    static func barButtonItem(image: UIImage, badgeText: String? = nil, onTap: @escaping () -> Void) -> UIBarButtonItem {
        let customView = Self.init()
        customView.update(with: ViewModel(
            image: image,
            badgeText: badgeText
        ))
        customView.addTapHandler(onTap)

        let navigationItem = UIBarButtonItem(customView: customView)
        return navigationItem
    }
}
