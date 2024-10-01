import Foundation
import UIKit

final class ProfileFeedbackScreenCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let itemSize = CGSize(width: 54, height: 54)
    }

    var image: UIImage? {
        didSet {
            self.itemView.image = self.image
        }
    }

    private lazy var itemView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = Appearance.itemSize.height / 2
        image.backgroundColor = .lightGray
        image.clipsToBounds = true
        return image
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.itemView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    // MARK: - Private api

    private func setupView() {
        self.clipsToBounds = false
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.size.equalTo(Appearance.itemSize)
        }
    }
}
