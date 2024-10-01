import UIKit
import PromiseKit
import SnapKit

protocol MyCardViewControllerProtocol: UIViewController {
    func set(model: MyCardViewModel)
    func show(client: PrimePassClient)
    func show(balance: BonusesViewModel)

	func update(certificates: CertificatesNavigationViewModel?)
}

final class MyCardViewController: UIViewController {
    let presenter: MyCardPresenterProtocol
    private lazy var myCardView = self.view as? MyCardView

    private lazy var cardInfoPresentationManager = FloatingControllerPresentationManager(
        context: .myCard,
        groupID: ProfileViewController.floatingControllerGroupID,
        sourceViewController: self
    )

    private lazy var stackCellsView = {
        let stackView = UIStackView(.vertical)
        stackView.spacing = 8.0
        return stackView
    }()
	private lazy var certificatesView = CertificatesNavigationView()
    private lazy var bonusesView = BonusesNavigationView()
	private lazy var activityIndicator = UIActivityIndicatorView()

    init(presenter: MyCardPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let view = MyCardView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	override func viewDidLoad() {
		super.viewDidLoad()

		self.placeCertificatesNavigationView()
		self.placeActivityIndicator()
	}

	private func placeCertificatesNavigationView() {
		guard let myCardView else { return }

        myCardView.scrollView.addSubview(stackCellsView)

        stackCellsView.addArrangedSubview(bonusesView)
        stackCellsView.addArrangedSubview(certificatesView)

        certificatesView.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        bonusesView.snp.makeConstraints { make in
            make.height.equalTo(75)
        }
        stackCellsView.snp.makeConstraints { make in
            make.top.equalTo(myCardView.cardView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }

        certificatesView.isHidden = true
	}

	private func placeActivityIndicator() {
		self.activityIndicator.isHidden = true

		guard UserDefaults[bool: "CertsEnabled"] else {
			return
		}

		self.view.insertSubview(self.activityIndicator, belowSubview: self.certificatesView)
		self.activityIndicator.make(.center, .equal, to: self.certificatesView)
		self.activityIndicator.startAnimating()
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.loadCard()
        presenter.loadBonusBalance()
    }
}

extension MyCardViewController: MyCardViewControllerProtocol {
    func set(model: MyCardViewModel) {
        self.myCardView?.isMyCardLoading = false

        self.myCardView?.fullName = model.fullName
        self.myCardView?.balance = model.balance
        myCardView?.gradeName = PGCMain.shared.featureFlags.appSetup.isMaisonDellosTarget
            ? model.discountPercent
            : model.gradeName
        self.myCardView?.userImage = model.userImage
        self.myCardView?.cardNumber = model.cardNumber
        self.myCardView?.qrImage = model.qrImage

        if model.shouldRetryQRCode {
            self.myCardView?.isQRCodeLoading = false
            self.myCardView?.isQRCodeRetry = true
        } else if model.isQRCodeLoading {
            self.myCardView?.isQRCodeRetry = false
            self.myCardView?.isQRCodeLoading = true
        } else {
            self.myCardView?.isQRCodeRetry = false
            self.myCardView?.isQRCodeLoading = false
        }

		self.activityIndicator.isHidden = !self.certificatesView.isHidden
    }

    func show(client: PrimePassClient) {
        let myCardInfo = MyCardInfoAssembly(client: client).makeModule()
        self.cardInfoPresentationManager.contentViewController = myCardInfo
        self.cardInfoPresentationManager.present()

		self.activityIndicator.isHidden = !self.certificatesView.isHidden
    }

    func show(balance: BonusesViewModel) {
        bonusesView.update(
            with: BonusesNavigationViewModel(
                balance: balance.bonusBalance,
                expirationAmount: balance.expiredBonuses,
                expirationDate: balance.expiredAt,
                onTap: nil
            )
        )
    }

	func update(certificates: CertificatesNavigationViewModel?) {
		self.activityIndicator.isHidden = true

		guard let certificates = certificates else {
			self.certificatesView.isHidden = true
			return
		}

		self.certificatesView.isHidden = false
		self.certificatesView.update(with: certificates)
	}
}

extension MyCardViewController: MyCardViewDelegate {
    func myCardViewDidSelectCard(_ view: MyCardView) {
        self.presenter.selectCard()
    }

	func myCardViewDidSelectCertificates(_ view: MyCardView) {
		self.presenter.selectCertificates()
	}

    func myCardViewDidRequestQRRefresh(_ view: MyCardView) {
        self.presenter.loadRandomCode()
    }

    func myCardViewDidRequestQRScan(_ view: MyCardView) {
        let qrScanner = QRScannerAssembly().makeModule()
        self.navigationController?.pushViewController(qrScanner, animated: true)
    }
}

