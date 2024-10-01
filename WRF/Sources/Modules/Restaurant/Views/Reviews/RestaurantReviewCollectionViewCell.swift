import SnapKit
import UIKit

final class RestaurantReviewCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let cornerRadius: CGFloat = 10
    }

    private lazy var itemView = RestaurantReviewItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with viewModel: RestaurantViewModel.Review) {
        self.itemView.date = viewModel.dateText
        self.itemView.image = viewModel.userImage
        self.itemView.name = viewModel.userName
        self.itemView.rating = viewModel.rating
        self.itemView.review = viewModel.text
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
