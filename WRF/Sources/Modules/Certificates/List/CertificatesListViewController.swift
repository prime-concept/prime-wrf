import UIKit

final class CertificatesListViewController: UIViewController {
	struct Appearance {
        var noDataTextColor = Palette.shared.textPrimary
		var noDataFont = UIFont.wrfFont(ofSize: 16)
        var backgroundColor = Palette.shared.backgroundColor0
	}

	private let appearance: Appearance = ApplicationAppearance.appearance()

	var onSelect: ((SingleCertificateViewModel) -> Void )? = nil

	private var certificates: [SingleCertificateViewModel] = []
	private static let reuseId = "certificate"

	override func viewDidLoad() {
		super.viewDidLoad()

        self.view.backgroundColorThemed = self.appearance.backgroundColor
		self.view.addSubview(self.tableView)
        self.tableView.make(
            .edges, .equal, to: view.safeAreaLayoutGuide, [44, 0, 0, 0],
            priorities: [999.layoutPriority]
        )

		self.view.addSubview(self.noDataView)
		self.noDataView.make(
            .edges, .equal, to: view.safeAreaLayoutGuide, [44, 28, 0, -28],
            priorities: [999.layoutPriority]
        )
	}

	private lazy var tableView = UITableView { (tableView: UITableView) in
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.register(CertificateCell.self, forCellReuseIdentifier: Self.reuseId)
		tableView.delegate = self
		tableView.dataSource = self

		tableView.contentInset.top = 5
		tableView.contentInset.bottom = 20

		tableView.rowHeight = 83
	}

	private lazy var noDataLabel = UILabel { (label: UILabel) in
		label.textColorThemed = self.appearance.noDataTextColor
		label.font = self.appearance.noDataFont
		label.textAlignment = .center
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
	}

	private lazy var noDataView = UIView { view in
		let imageView = UIImageView(image: UIImage(named: "search"))
		imageView.contentMode = .scaleAspectFit

		let topSpacer = UIView.vSpacer(growable: 0)
		let bottomSpacer = UIView.vSpacer(growable: 0)

		let stack = UIStackView.vertical(
			topSpacer,
			imageView,
			.vSpacer(20),
			self.noDataLabel,
			bottomSpacer
		)

		view.addSubview(stack)
		stack.make(.edges, .equalToSuperview)

		topSpacer.make(.height, .equal, to: CGFloat(171) / CGFloat(330), of: bottomSpacer)
	}

	func update(with viewModel: CertificatesViewModel.Tab) {
		self.certificates = viewModel.certificates
		self.tableView.reloadData()

		self.tableView.isHidden = self.certificates.isEmpty
		self.noDataView.isHidden = !self.tableView.isHidden

		self.noDataLabel.attributedText = viewModel.noDataHint.attributed()
			.alignment(.center)
			.lineBreakMode(.byWordWrapping)
			.foregroundColor(self.appearance.noDataTextColor)
			.font(self.appearance.noDataFont)
			.lineHeight(22)
			.string()
	}
}

extension CertificatesListViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		self.certificates.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseId, for: indexPath)
		cell.selectionStyle = .none

		with(cell as? CertificateCell) { cell in
			let certificate = self.certificates[indexPath.row]
			cell?.certificateView.update(with: certificate)

			cell?.certificateView.removeTapHandler()
			cell?.certificateView.addTapHandler {
				self.onSelect?(certificate)
			}
		}

		return cell
	}
}
