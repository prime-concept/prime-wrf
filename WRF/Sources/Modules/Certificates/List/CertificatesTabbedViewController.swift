import UIKit
import Tabman
import Pageboy

enum CertificatesTab: Int {
    case new
    case my
    case history
    
    var title: String {
        switch self {
        case .new:
            return "New"
        case .my:
            return "My"
        case .history:
            return "History"
        }
    }
}

protocol CertificatesTabbedViewProtocol: UIViewController {
	func update(with viewModel: CertificatesViewModel)
	func presentTab(_ tab: CertificatesTab)
}

final class CertificatesTabbedViewController: TabmanViewController {
	struct Appearance {
		var backgroundColor = UIColor.white

        var navigationTintColor = Palette.shared.textPrimary
		var titleFont = UIFont.wrfFont(ofSize: 17)

		var pointsTextColor = Palette.shared.textPrimary
		var pointsFont = UIFont.wrfFont(ofSize: 17, weight: .medium)

		var barButtonTextColor = Palette.shared.textPrimary
		var barButtonFont = UIFont.wrfFont(ofSize: 17)
	}

	private let presenter: CertificatesPresenterProtocol

	private var defaultPage: CertificatesTab = .new

	private lazy var newCertificatesViewController = CertificatesListViewController()
	private lazy var myCertificatesViewController = CertificatesListViewController()
	private lazy var oldCertificatesViewController = CertificatesListViewController()

	private var tabBar: TMBar.WRFBar?

	private lazy var barItems = [
		WRFBarItem(title: "Новые", viewController: self.newCertificatesViewController),
		WRFBarItem(title: "Мои", viewController: self.myCertificatesViewController),
		WRFBarItem(title: "История", viewController: self.oldCertificatesViewController)
	]

	private lazy var barDataSource = TabDataSource(
		items: self.barItems,
		offset: 0
	)

	private let appearance: Appearance = ApplicationAppearance.appearance()
	private lazy var tabbedView = CertificatesTabbedView()

	init(presenter: CertificatesPresenterProtocol) {
		self.presenter = presenter
		super.init(nibName: nil, bundle: nil)

		Notification.onReceive(.certificatesLoaded) { [weak self] notification in
			let viewModel = notification.userInfo?["viewModel"] as? CertificatesViewModel
			
			guard let viewModel = viewModel else {
				return
			}

			self?.update(with: viewModel)
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.addSubview(self.tabbedView)
		self.tabbedView.make(.edges, .equalToSuperview, priorities: [999.layoutPriority])
		self.view.backgroundColor = self.appearance.backgroundColor

		self.setupTabBar()
		self.dataSource = self.barDataSource
		self.automaticallyAdjustsChildInsets = true

        navigationController?.navigationBar.tintColorThemed = appearance.navigationTintColor

		self.navigationItem.titleView = UILabel { (label: UILabel) in
			label.text = "Сертификаты"
			label.textColorThemed = self.appearance.navigationTintColor
			label.font = self.appearance.titleFont
		}

		self.navigationItem.leftBarButtonItem = self.makeBackBarItem()
		self.navigationItem.rightBarButtonItem = self.makeRightBarItem()

        self.newCertificatesViewController.onSelect = { [weak self] certificate in
            AnalyticsReportingService.shared.didSelectCertificate(id: certificate.id,
                                                                  tabName: CertificatesTab.new.title)
            self?.presenter.didSelectNew(certificate: certificate)
        }
        
        self.myCertificatesViewController.onSelect = { [weak self] certificate in
            AnalyticsReportingService.shared.didSelectCertificate(id: certificate.id,
                                                                  tabName: CertificatesTab.my.title)
            self?.presenter.didSelectMy(certificate: certificate)
        }
        
        self.oldCertificatesViewController.onSelect = { [weak self] certificate in
            AnalyticsReportingService.shared.didSelectCertificate(id: certificate.id,
                                                                  tabName: CertificatesTab.history.title)
            self?.presenter.didSelectOld(certificate: certificate)
        }
    }
    
    // MARK: - Public API

    override func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: PageIndex,
        direction: NavigationDirection,
        animated: Bool
    ) {
        
        let selectedTabName = CertificatesTab(rawValue: index)?.title ?? ""
        AnalyticsReportingService.shared.didTapOnCertificatesTab(name: selectedTabName)
    }

	private lazy var pointsLabel = UILabel { (label: UILabel) in
		label.font = self.appearance.pointsFont
		label.textColorThemed = self.appearance.pointsTextColor
	}

	private lazy var currencyLabel = UIImageView { (imageView: UIImageView) in
		imageView.image = UIImage(named: "certificate-currency")
		imageView.make(.size, .equal, [17, 17])
	}

	private func makeBackBarItem() -> UIBarButtonItem {
		let item = UIBarButtonItem(customView: UIView {
			let stack = UIStackView.horizontal(
				UIImageView(image: UIImage(named: "profile-back-arrow")),
				UILabel { (label: UILabel) in
					label.text = "Назад"
					label.textColorThemed = self.appearance.barButtonTextColor
					label.font = self.appearance.barButtonFont
				}
			)
			stack.spacing = 8
			$0.addSubview(stack)
			stack.make(.edges, .equalToSuperview)
		})

		item.customView?.addTapHandler { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}

        item.tintColorThemed = appearance.navigationTintColor

		return item
	}

	private func makeRightBarItem() -> UIBarButtonItem {
		let item = UIBarButtonItem(customView: UIView {
			let stack = UIStackView.horizontal(
				self.pointsLabel, self.currencyLabel
			)
			stack.spacing = 8
			$0.addSubview(stack)
			stack.make(.edges, .equalToSuperview)
		})

		return item
	}

	// MARK: - Private API

	private func setupTabBar() {
		let barLocation: BarLocation = .custom(
			view: self.tabbedView.tabContainerView,
			layout: { bar in
				bar.translatesAutoresizingMaskIntoConstraints = false
				bar.snp.makeConstraints { make in
					make.top.equalToSuperview()
					make.leading.trailing.bottom.equalToSuperview()
				}
			}
		)

		let tabBar = self.tabbedView.makeTabBar()
		self.tabBar = tabBar

		self.addBar(tabBar, dataSource: self.barDataSource, at: barLocation)
		self.scrollToPage(.at(index: self.defaultPage.rawValue), animated: false)
	}
}

extension CertificatesTabbedViewController: CertificatesTabbedViewProtocol {
	func presentTab(_ tab: CertificatesTab) {
		self.scrollToPage(.at(index: tab.rawValue), animated: true)
	}

	func update(with viewModel: CertificatesViewModel) {
		_ = self.view

		self.pointsLabel.text = viewModel.pointsAvailable
		
		self.newCertificatesViewController.update(with: viewModel.new)
		self.myCertificatesViewController.update(with: viewModel.my)
		self.oldCertificatesViewController.update(with: viewModel.old)
		
		self.tabBar!.items![0].badgeValue = viewModel.new.certificates.count.description
		self.tabBar?.items?[1].badgeValue = viewModel.my.certificates.count.description
		self.tabBar?.items?[2].badgeValue = viewModel.old.certificates.count.description
	}
}
