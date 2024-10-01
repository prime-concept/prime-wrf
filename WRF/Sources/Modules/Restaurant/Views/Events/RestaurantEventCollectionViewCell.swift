import SnapKit
import UIKit

final class RestaurantEventCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let cornerRadius: CGFloat = 10
    }

    private lazy var itemView = RestaurantEventItemView()

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

    func configure(with viewModel: RestaurantViewModel.Event) {
        self.itemView.title = viewModel.title
        self.itemView.date = viewModel.date
        self.itemView.imageURL = viewModel.imageURL
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
