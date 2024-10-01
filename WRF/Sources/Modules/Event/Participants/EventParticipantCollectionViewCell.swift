import SnapKit
import UIKit

final class EventParticipantCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let cornerRadius: CGFloat = 10
        static let itemHeight: CGFloat = 125
    }

    private lazy var itemView = EventParticipantsItemView()

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with model: EventViewModel.Participant) {
        self.itemView.title = model.title
        self.itemView.address = model.address
        self.itemView.imageURL = model.imageURL
        self.itemView.logoURL = model.logoURL
        self.itemView.distance = model.distanceText
        self.itemView.price = model.price
        self.itemView.rating = model.rating
        self.itemView.ratingText = model.assessmentsCountText
        self.itemView.isRatingHidden = model.rating == 0
    }

    // MARK: - Private API

    private func setupView() {
        self.clipsToBounds = false
        self.backgroundColor = .clear

        self.itemView.clipsToBounds = true
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
