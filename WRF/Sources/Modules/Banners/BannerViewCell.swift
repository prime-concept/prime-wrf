import UIKit

final class BannerViewCell: UITableViewCell, Reusable {
	private lazy var bannerView = BannerView()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		backgroundColor = .clear

		contentView.addSubview(bannerView)
		bannerView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func update(with viewModel: BannerViewModel) {
		bannerView.update(with: viewModel)
	}
}
