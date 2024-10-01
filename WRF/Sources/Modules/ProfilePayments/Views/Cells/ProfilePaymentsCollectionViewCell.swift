import SnapKit
import UIKit

final class ProfilePaymentsCollectionViewCell: UICollectionViewCell, Reusable {
    private enum Appearance {
        static let cornerRadius: CGFloat = 10
        static let itemHeight: CGFloat = 100
    }

    private lazy var itemView = ProfilePaymentsItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with model: ProfilePaymentViewModel) {
        self.itemView.code = model.number
        self.itemView.date = model.date
        self.itemView.image = model.image
    }

    private func setupView() {
        self.backgroundColor = .clear

        self.itemView.layer.cornerRadius = Appearance.cornerRadius
        self.contentView.addSubview(self.itemView)

        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.height.equalTo(Appearance.itemHeight)
        }
    }
}
