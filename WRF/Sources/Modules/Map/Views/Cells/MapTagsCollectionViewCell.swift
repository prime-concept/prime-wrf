import SnapKit
import UIKit

final class MapTagsCollectionViewCell: UICollectionViewCell, Reusable {
    struct Appearance {
        let shadowViewInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: -15)
        let shadowImageCaps = UIEdgeInsets(top: 8, left: 23, bottom: 22, right: 23)
        let itemHeight: CGFloat = 36
        var shouldUseImageShadow = true
    }

    private let appearance: Appearance = ApplicationAppearance.appearance()

    private lazy var itemView = SubtitleTagItemView()
    private lazy var shadowView = UIView()

    override var isSelected: Bool {
        didSet {
            self.itemView.isSelected = self.isSelected
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.itemView.clear()
    }

    func configure(with viewModel: MapTagViewModel) {
        self.itemView.title = viewModel.title
        self.itemView.imageURL = viewModel.imageURL
        self.itemView.subtitle = "\(viewModel.count)"
    }

    private func setupView() {
        self.clipsToBounds = false
        self.backgroundColor = .clear

        if appearance.shouldUseImageShadow {
            let image = #imageLiteral(resourceName: "map-tags-resizable-background").resizableImage(
                withCapInsets: appearance.shadowImageCaps
            )
            self.shadowView.layer.contents = image.cgImage
        }

        self.shadowView.clipsToBounds = false

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(appearance.itemHeight)
        }

        self.contentView.addSubview(self.shadowView)
        self.shadowView.translatesAutoresizingMaskIntoConstraints = false
        self.shadowView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(appearance.shadowViewInsets)
        }
    }
}
