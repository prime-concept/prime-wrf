import UIKit

protocol CertificateDetailsViewProtocol: UIViewController {
    func setup(with viewModel: CertificateDetailsViewModel)
	func showLoading()
	func hideLoading()
}

final class CertificateDetailsViewController: CurtainViewController {
	struct Appearance {
		let backgroudColor = Palette.shared.backgroundColor0
		let curtainBackdropColor = Palette.shared.black.withAlphaComponent(0.7)
	}

	private let appearance: Appearance = ApplicationAppearance.appearance()

    private let presenter: CertificatePresenterInput

    private lazy var headerView = CertificateDetailsHeaderView()
    private lazy var purchaseView = CertificatePurchaseView()
	private lazy var usageView = CertificateUsageView()
	private lazy var expirationView = CertificateExpirationView()
	private lazy var notificationView = CertificateNotificationView()

	private lazy var contentStackView = UIStackView.vertical(
		self.headerView,
		self.purchaseView,
		self.usageView,
		self.expirationView,
		self.notificationView
	)

    init(presenter: CertificatePresenterInput) {
        self.presenter = presenter
		let container = UIView()
		container.backgroundColorThemed = self.appearance.backgroudColor

		super.init(
			with: container,
			backgroundColor: appearance.curtainBackdropColor,
			curtainViewBackgroundColor: appearance.backgroudColor
		)

		container.addSubview(self.contentStackView)
		self.contentStackView.make(.edges, .equalToSuperview)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter.didLoad()
    }
}

extension CertificateDetailsViewController: CertificateDetailsViewProtocol {
	func showLoading() {
		self.purchaseView.showLoading()
		self.notificationView.showLoading()
	}

	func hideLoading() {
		self.purchaseView.hideLoading()
		self.notificationView.hideLoading()
	}

    func setup(with viewModel: CertificateDetailsViewModel) {
		self.contentStackView.arrangedSubviews.forEach { $0.isHidden = true }

		if let header = viewModel.header {
			self.headerView.update(with: header)
			self.headerView.isHidden = false
		}

        if case let .new(purchaseViewModel) = viewModel.details {
            self.purchaseView.setup(with: purchaseViewModel)
			self.purchaseView.isHidden = false
        }

		if case let .my(instructions) = viewModel.details {
			self.usageView.setup(with: instructions)
			self.usageView.isHidden = false
		}

		if case let .old(info) = viewModel.details {
			self.expirationView.setup(with: info)
			self.expirationView.isHidden = false
		}

		if case let .notification(info) = viewModel.details {
			self.notificationView.setup(with: info)
			self.notificationView.isHidden = false
		}
    }
}
