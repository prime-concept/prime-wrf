import PromiseKit

extension Notification.Name {
	static let certificatesLoaded = Notification.Name("certificatesLoaded")
}

protocol MyCardPresenterProtocol: AnyObject {
    func loadCard()
    func loadRandomCode()
    func loadBonusBalance()

    func selectCard()
	func selectCertificates()
}

final class MyCardPresenter: MyCardPresenterProtocol {
    private static let backgroundQueue = DispatchQueue.global(qos: .userInitiated)

    weak var viewController: MyCardViewControllerProtocol?

    private let clientEndpoint: PrimePassClientEndpointProtocol
    private let loyaltyEndpoint: PrimePassLoyaltyEndpointProtocol
    private let bonusEndpoint: BonusEndpointProtocol
    private let clientService: ClientServiceProtocol
    private let authService: AuthServiceProtocol

    private var client: PrimePassClient?

    private var randomCodeResponse: PrimePassLoyaltyRandomCodeResponse? {
        didSet {
            self.setupTimerForRefresh(response: self.randomCodeResponse)
        }
    }

    private var qrCardRefreshTimer: Timer?

	private var pointsNumberFormatter = with(NumberFormatter()) { numberFormatter in
		numberFormatter.usesGroupingSeparator = true
		numberFormatter.groupingSeparator = " "
		numberFormatter.groupingSize = 3
	}

    private let inputBonusDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private let outputBonusDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()

    init(
        clientEndpoint: PrimePassClientEndpointProtocol,
        loyaltyEndpoint: PrimePassLoyaltyEndpointProtocol,
        clientService: ClientServiceProtocol,
        authService: AuthServiceProtocol,
        bonusEndpoint: BonusEndpointProtocol
    ) {
        self.clientEndpoint = clientEndpoint
        self.loyaltyEndpoint = loyaltyEndpoint
        self.clientService = clientService
        self.authService = authService
        self.bonusEndpoint = bonusEndpoint

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.updateCard),
            name: .clientUpdated,
            object: nil
        )

		Notification.onReceive(.certificatesChanged) { [weak self] _ in
			self?.loadCard(code: false, certs: UserDefaults[bool: "CertsEnabled"])
		}
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	func loadCard() {
		self.loadCard(code: true, certs: UserDefaults[bool: "CertsEnabled"])
	}

	private func loadCard(code: Bool, certs: Bool) {
        guard let userID = self.authService.authorizationData?.userID else {
            return
        }

        let queue = type(of: self).backgroundQueue
        queue.promise {
            self.clientService.retrieve()
                .done { client in
                    guard let client = client else {
                        return
                    }
                    self.client = client
                    self.viewController?.set(model: self.makeViewModel(client: client, randomCode: nil))
                }
        }.then(on: queue) { _ in
            self.clientEndpoint.retrieve(id: userID).result
        }.done(on: queue) { response in
            guard let client = response.data else {
                return
            }
            self.client = client
            self.clientService.save(client: client)

			if code {
				self.loadRandomCode()
			}

			if certs {
				self.loadCertificates()
			}

            DispatchQueue.main.async {
                self.viewController?.set(model: self.makeViewModel(client: client, randomCode: nil))
            }
        }.catch { error in
            print("my card presenter: error retrieving client and card \(String(describing: error))")
            self.randomCodeResponse = nil
            if let client = self.client {
                self.viewController?.set(
                    model: self.makeViewModel(
                        client: client,
                        randomCode: self.randomCodeResponse,
                        isQRCodeError: true
                    )
                )
            }
        }
    }

    @objc
    func loadRandomCode() {
        guard let client = self.client else {
            return
        }

        DispatchQueue.main.async {
            self.viewController?.set(model: self.makeViewModel(client: client, randomCode: nil))
        }

        let queue = Self.backgroundQueue
        queue.promise {
            self.clientService.retrieveRandomCode()
        }.then(on: queue) { response -> Promise<PrimePassLoyaltyRandomCodeResponse> in
            if let response = response {
                if let expiredAt = response.expiredAt,
                   expiredAt.timeIntervalSince1970 - Date().timeIntervalSince1970 > 0 {
                    self.randomCodeResponse = response

                    DispatchQueue.main.async {
                        self.viewController?.set(model: self.makeViewModel(client: client, randomCode: response))
                    }
                } else {
                    self.clientService.removeRandomCode()
                }
            }
            return self.loyaltyEndpoint.retrieveRandomCode(cardNumber: client.cardNumber).result
        }.done { response in
            if response.code == nil || response.createdAt == nil {
                throw Error.refreshFailed
            }

            self.randomCodeResponse = response
            self.clientService.saveRandomCode(response)

            self.viewController?.set(model: self.makeViewModel(client: client, randomCode: response))
        }.catch { _ in
            self.randomCodeResponse = nil
            self.viewController?.set(model: self.makeViewModel(client: client, randomCode: nil, isQRCodeError: true))
        }
    }

	private func loadCertificates() {
		guard let client = ClientPersistenceService.shared.client else {
			return
		}

		DispatchQueue.global().promise {
			when(fulfilled:
				 PrimePassCertificatesEndpoint.shared.newCertificates(for: client.userID).result,
				 PrimePassCertificatesEndpoint.shared.myCertificates(for: client.userID).result
			)
		}.done(on: .main) { (response: (
			PrimePassArrayResponse<PrimePassCertificate>,
			PrimePassArrayResponse<PrimePassCoupon>)
		) in
			let (certsResponse, couponsResponse) = response

			let certificatesViewModel = self.makeCertificatesViewModel(
				new: certsResponse.data ?? [],
				my: couponsResponse.data ?? []
			)

			let imageURLs = certificatesViewModel.imageURLs(first: 3)
			let newCount = certificatesViewModel.new.certificates.count.description

			let navigationViewModel = CertificatesNavigationViewModel(
				cardImageURLs: imageURLs,
				count: newCount,
				onTap: {
                    AnalyticsReportingService.shared.didTapOnCertificates()
					let controller = CertificatesAssembly(viewModel: certificatesViewModel).makeModule()
					self.viewController?.navigationController?.pushViewController(controller, animated: true)
				}
			)

			self.viewController?.update(certificates: navigationViewModel)

			NotificationCenter.default.post(Notification(
				name: .certificatesLoaded,
				userInfo: ["viewModel": certificatesViewModel])
			)
		}
		.catch { error in
			print("FAILED TO LOAD CERTIFICATES:\n\(error)")
			self.viewController?.update(certificates: nil)
		}
	}

    func loadBonusBalance() {
        guard let client = ClientPersistenceService.shared.client else { return }
        DispatchQueue.global(qos: .userInitiated).promise {
            self.bonusEndpoint.retrieveBonus(clientID: "\(client.userID)").result
        }.map { response in
            BonusesViewModel(
                bonusBalance: "бонусных баллов".pluralized(
                    "%d %@",
                    response.data.balance,
                    Self.pointsNumberFormatter
                ),
                expiredBonuses: "баллов сгорят".pluralized(
                    "%d %@",
                    response.data.expiredBonuses.first?.estimateDebit ?? 0
                ),
                expiredAt: self.convert(date: response.data.expiredBonuses.first?.expiredAt)
            )
        }.done(on: .main) { BonusesViewModel in
            self.viewController?.show(balance: BonusesViewModel)
        }.catch { error in
            print("the request of bonus balance has the error: \(String(describing: error))")
        }
    }

	func makeCertificatesViewModel(new: [PrimePassCertificate], my: [PrimePassCoupon]) -> CertificatesViewModel {
		let client = ClientPersistenceService.shared.client!
		let today = Date().down(to: .day)

		let newCertificates = new.filter { certificate in
			certificate.endDate ?? .distantFuture >= today
		}

		var activeCertificates = [PrimePassCoupon]()
		var oldCertificates = [PrimePassCoupon]()

		my.forEach { certificate in
			if (certificate.endDate ?? .distantFuture) >= today {
				activeCertificates.append(certificate)
				return
			}

			oldCertificates.append(certificate)
		}

		let newTab = CertificatesViewModel.Tab(
			title: "Новые",
			certificates: newCertificates.map { self.makeSingleCertificateViewModel(from: $0, iconName: "certificate-add") },
			noDataHint: "Совсем скоро здесь появятся персональные предложения для вас!"
		)

		let myTab = CertificatesViewModel.Tab(
			title: "Мои",
			certificates: activeCertificates.map { self.makeSingleCertificateViewModel(from: $0, iconName: "certificate-checkmark") },
			noDataHint: "Приобретенных сертификатов нет.\nВы можете посмотреть доступные варианты на экране \"Новые\""
		)

		let historyTab = CertificatesViewModel.Tab(
			title: "История",
			certificates: oldCertificates.map { self.makeSingleCertificateViewModel(from: $0, iconName: "certificate-clock") },
			noDataHint: "Завершенных сертификатов нет"
		)

		let certificatesViewModel = CertificatesViewModel(
			new: newTab,
			my: myTab,
			old: historyTab,
			pointsAvailable: Self.pointsNumberFormatter.string(from: client.bonusBalance) ?? "0"
		)

		return certificatesViewModel
	}

	private static let pointsNumberFormatter = with(NumberFormatter()) { numberFormatter in
		numberFormatter.usesGroupingSeparator = true
		numberFormatter.groupingSeparator = " "
		numberFormatter.groupingSize = 3
	}

	private func makeSingleCertificateViewModel(
		from certificate: PrimePassCertificate,
		iconName: String
	) -> SingleCertificateViewModel {
		SingleCertificateViewModel(
			id: "\(certificate.id)",
			title: certificate.name,
			iconURL: certificate.iconURL,
			description: certificate.description ?? "",
			price: Self.pointsNumberFormatter.string(from: certificate.cost),
			endDate: certificate.endDate,
			activeDays: certificate.activeDays,
			actionIcon: UIImage(named: iconName)!
		)
	}

	func makeSingleCertificateViewModel(
		from coupon: PrimePassCoupon,
		iconName: String
	) -> SingleCertificateViewModel {
		SingleCertificateViewModel(
			id: "\(coupon.id)",
			title: coupon.name,
			iconURL: coupon.iconURL,
			description: coupon.description ?? "",
			price: Self.pointsNumberFormatter.string(from: coupon.cost),
			code: coupon.code,
			endDate: coupon.endDate,
			activeDays: coupon.activeDays,
			actionIcon: UIImage(named: iconName)!
		)
	}

    func selectCard() {
        guard let client = self.client else {
            return
        }
        AnalyticsReportingService.shared.didTapOnLoyaltyCard()
        self.viewController?.show(client: client)
    }

	func selectCertificates() {
        //TODO: - add implementation or remove method
	}

    // MARK: - Private API

    private func setupTimerForRefresh(response: PrimePassLoyaltyRandomCodeResponse?) {
        guard let response = response, let expiredAt = response.expiredAt else {
            self.qrCardRefreshTimer?.invalidate()
            self.qrCardRefreshTimer = nil
            return
        }

        let interval = expiredAt.timeIntervalSinceNow
        print("my card presenter: next qr code refresh after \(interval) sec")
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            print("my card presenter: fired timer to refresh qr code")
            guard let strongSelf = self else {
                return
            }

            strongSelf.randomCodeResponse = nil

            DispatchQueue.main.async {
                strongSelf.client.flatMap {
                    strongSelf.viewController?.set(model: strongSelf.makeViewModel(client: $0, randomCode: nil))
                }
            }

            strongSelf.loadRandomCode()
        }

        self.qrCardRefreshTimer = timer
    }

    @objc
    private func updateCard() {
        type(of: self).backgroundQueue.promise {
            self.clientService.retrieve()
        }
        .compactMap { $0 }
        .done { client in
            self.client = client
            self.viewController?.set(model: self.makeViewModel(client: client, randomCode: self.randomCodeResponse))

            self.loadRandomCode()
        }.cauterize()
    }

    private func makeViewModel(
        client: PrimePassClient,
        randomCode: PrimePassLoyaltyRandomCodeResponse?,
        isQRCodeError: Bool = false
    ) -> MyCardViewModel {
        .init(
            fullName: "\(client.name ?? "") \(client.surname ?? "")".trimmingCharacters(in: .whitespaces),
            gradeName: client.card.gradeName, 
            discountPercent: "\(client.courseBonus * 100 / (client.courseRub == 0 ? 1 : client.courseRub))%",
			balance: "баллов".pluralized("%d %@", client.card.bonusBalance, Self.pointsNumberFormatter),
            userImage: client.photo?.asImage,
            qrImage: "\(randomCode?.code ?? "no code")".asQrImage,
            cardNumber: client.cardNumber ,
            shouldRetryQRCode: isQRCodeError,
            isQRCodeLoading: self.randomCodeResponse?.code == nil
        )
    }

    // MARK: - Error

    enum Error: Swift.Error {
        case refreshFailed
    }
}

extension MyCardPresenter: ProfileClientModuleInput {
    func set(client: PrimePassClient) {
        guard let client = self.client else {
            return
        }
        self.client = client
        self.viewController?.set(model: self.makeViewModel(client: client, randomCode: self.randomCodeResponse))
    }
}

extension NumberFormatter {
	func string(from value: Int) -> String? {
		self.string(from: NSNumber(value: value))
	}

	func string(from value: Float) -> String? {
		self.string(from: NSNumber(value: value))
	}

	func string(from value: Double) -> String? {
		self.string(from: NSNumber(value: value))
	}
}

extension CertificatesViewModel {
	func imageURLs(first n: Int) -> [URL] {
		let new = self.new.certificates

		let images = Array(new.compactMap(\.iconURL).prefix(3))

		return images
	}
}

private extension MyCardPresenter {
    func convert(date: Date?) -> String {
        guard let date else { return "" }
        return outputBonusDateFormatter.string(from: date)
    }
}
