import SnapKit
import UIKit

protocol VideoEventCollectionViewCellDelegate: AnyObject {
    func videoEventCollectionViewCell(
        _ cell: VideoEventCollectionViewCell,
        didShare event: EventItemViewModel
    )
}

final class VideoEventCollectionViewCell: UICollectionViewCell, Reusable {
    enum Appearance {
        static let itemHeight: CGFloat = 300
    }

    weak var delegate: VideoEventCollectionViewCellDelegate?
    private var model: EventItemViewModel?

    private lazy var itemView: VideoEventItemView = {
        let view = VideoEventItemView()
        return view
    }()

    override func prepareForReuse() {
        super.prepareForReuse()

        self.model = nil
        self.itemView.clear()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.itemView.superview == nil {
            self.setupView()
        }
    }

    func configure(with event: EventItemViewModel) {
        self.model = event

        self.itemView.title = event.title
        self.itemView.imageURL = event.imageURL
        self.itemView.author = event.videoInfo?.author ?? ""
        self.itemView.isLive = event.videoInfo?.isLive ?? false

        self.itemView.onShareButtonClick = { [weak self] in
            guard let model = self?.model, let strongSelf = self else {
                return
            }

            strongSelf.delegate?.videoEventCollectionViewCell(strongSelf, didShare: model)
        }
    }

    // MARK: - Private

    private func setupView() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.itemView)
        self.itemView.translatesAutoresizingMaskIntoConstraints = false
        self.itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.height.equalTo(Appearance.itemHeight)
        }
    }
}
