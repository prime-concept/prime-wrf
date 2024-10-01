import SnapKit
import UIKit

final class RestaurantPhotoCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let cornerRadius: CGFloat = 8
    }

    private lazy var itemView = RestaurantPhotoItemView()

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

    func configure(with image: URL) {
        self.itemView.imageURL = image
    }

    private func setupView() {
        self.clipsToBounds = false
        self.backgroundColor = .clear

        self.itemView.clipsToBounds = true
        self.itemView.layer.cornerRadius = Appearance.cornerRadius

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
