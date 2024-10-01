import UIKit

final class EventCarouselView: UIView {
	struct Appearance {
        let backgroundColor = Palette.shared.clear
		let carouselBackgroundColor = Palette.shared.clear

		let spacing: CGFloat = 8
		let collectionInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
	}

	let appearance: Appearance

	var didToggleFavorite: ((Event.IDType, Bool) -> Void)?
	var didSelectEvent: ((Event.IDType) -> Void)?
	var didScrollToEnd: (() -> Void)?

	var models: [EventCellViewModel] = []

	init(models: [EventCellViewModel], appearance: Appearance = .init()) {
		self.models = models
		self.appearance = appearance
		
		super.init(frame: .zero)

		self.setupSubviews()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupSubviews() {
		self.backgroundColorThemed = self.appearance.backgroundColor

		self.addSubview(self.carousel)
		self.carousel.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.leading.trailing.equalToSuperview()
		}
	}

    private let carouselCellAppearance = EventCarouselViewCell.Appearance()

	override var intrinsicContentSize: CGSize {
		var size = carouselCellAppearance.selfSize
		size.width = EventCarouselView.noIntrinsicMetric
		return size
	}

	private lazy var carouselLayout: UICollectionViewLayout = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumInteritemSpacing = self.appearance.spacing
		layout.estimatedItemSize = carouselCellAppearance.selfSize
		return layout
	}()

	private lazy var carousel: UICollectionView = {
		let collectionView = UICollectionView(
			frame: .zero, collectionViewLayout: self.carouselLayout
		)
		collectionView.backgroundColorThemed = self.appearance.carouselBackgroundColor
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.register(cellClass: EventCarouselViewCell.self)
		collectionView.contentInset = self.appearance.collectionInsets
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()

	func update(with viewModels: [EventCellViewModel]) {
		self.models = viewModels
		self.carousel.reloadData()
	}
}

extension EventCarouselView: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		self.models.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let cell: EventCarouselViewCell = collectionView.dequeueReusableCell(for: indexPath)
		let model = self.models[indexPath.row]
		cell.update(with: model)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if let cell = cell as? EventCarouselViewCell {
			let model = self.models[indexPath.row]
			cell.didToggleFavorite = { [weak self] isFavorite in
				self?.didToggleFavorite?(model.id, isFavorite)
			}
		}

		if indexPath.row >= self.models.count - 3 {
			self.didScrollToEnd?()
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		let model = self.models[indexPath.row]
		self.didSelectEvent?(model.id)
	}
}
