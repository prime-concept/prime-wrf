import SnapKit
import UIKit

final class SearchEventTagCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let itemHeight: CGFloat = 36
    }

    private(set) lazy var itemView = SubtitleTagItemView()

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

    // MARK: - Public api

    func configure(with model: SearchEventTagViewModel) {
        self.itemView.title = model.title
        self.itemView.imageURL = model.imageURL
        self.itemView.subtitle = model.eventsCount.flatMap { "\($0)" }
        self.itemView.isSelected = model.isSelected
    }

    // MARK: - Private api

    private func setupView() {
        self.clipsToBounds = false
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Appearance.itemHeight)
        }
    }
}
