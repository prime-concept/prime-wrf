import UIKit
import SnapKit

final class HomeScreenEventsCell: UITableViewCell, Reusable {
	struct Appearance {
        let backgroundColor = Palette.shared.clear
	}

	private lazy var carousel: EventCarouselView = {
		let carousel = EventCarouselView(models: [])
		carousel.didToggleFavorite = { [weak self] id, isFavorite in
			self?.didToggleFavorite?(id, isFavorite)
		}
		carousel.didSelectEvent = { [weak self] id in
			self?.didSelectEvent?(id)
		}
		carousel.didScrollToEnd = { [weak self] in
			self?.didScrollToEnd?()
		}
		return carousel
	}()

	var didToggleFavorite: ((Event.IDType, Bool) -> Void)?
	var didSelectEvent: ((Event.IDType) -> Void)?
	var didScrollToEnd: (() -> Void)?

	private let appearance = Appearance()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
        
		backgroundColorThemed = appearance.backgroundColor

		contentView.addSubview(carousel)
		carousel.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func update(with models: [EventCellViewModel]) {
		carousel.update(with: models)
	}
}

