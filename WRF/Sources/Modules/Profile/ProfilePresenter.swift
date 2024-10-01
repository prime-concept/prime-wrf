import Foundation
import PromiseKit

extension Notification.Name {
	static let showLoyaltyCard = Notification.Name(rawValue: "Profile.ShowLoyaltyCard")
	static let showBookingHistory = Notification.Name(rawValue: "Profile.ShowBookingHistory")
}

protocol ProfilePresenterProtocol: AnyObject {
    func didAppear()
    func loadClient()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var viewController: ProfileViewControllerProtocol?

    private let hostessBookingEndpoint: HostessBookingEndpointProtocol
    private let endpoint: PrimePassClientEndpointProtocol
    private let clientService: ClientServiceProtocol
    private let authService: AuthServiceProtocol

    // MARK: – Initialization

    init(
        hostessBookingEndpoint: HostessBookingEndpointProtocol,
        endpoint: PrimePassClientEndpointProtocol,
        clientService: ClientServiceProtocol,
        authService: AuthServiceProtocol
    ) {
        self.hostessBookingEndpoint = hostessBookingEndpoint
        self.endpoint = endpoint
        self.clientService = clientService
        self.authService = authService

        self.registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    func didAppear() {
        if PGCMain.shared.featureFlags.profile.shouldUpdateActiveBookingsCount {
            updateActiveBookingsCount()
        }
    }

	@objc
	private func updateActiveBookingsCount() {
		guard let userID = self.authService.authorizationData?.userID else {
			return
		}

		DispatchQueue.global(qos: .userInitiated).promise {
			self.hostessBookingEndpoint.activeBookingsCount(for: userID).result
		}.done { response in
			guard response.isSuccessful,
				  let badgeCount = response.data
			else {
				return
			}
			self.viewController?.setActiveBookingsCount(badgeCount)
		}.catch { error in
			print("profile presenter: error loading count for active bookings \(String(describing: error.localizedDescription))")
		}
	}

    @objc
    func loadClient() {
        self.showAppropriateUserInterface()

        guard let userID = self.authService.authorizationData?.userID else {
            return
        }

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.clientService.retrieve()
        }.done(on: .main) { client in
            if let client {
                self.viewController?.setProfileImage(.authorized(self.image(for: client)))
            } else {
                self.viewController?.setProfileImage(.unauthorized)
            }
        }.then(on: queue) {
            self.endpoint.retrieve(id: userID).result
        }.done(on: .main) { response in
            guard response.status == .ok, let client = response.data else {
                return
            }
            self.clientService.save(client: client)
            self.viewController?.setProfileImage(.authorized(self.image(for: client)))
        }.ensure(on: .main) {
            self.showAppropriateUserInterface()
        }.catch { error in
            print("profile presenter: error loading client \(String(describing: error.localizedDescription))")
        }
    }

    // MARK: - Private API

    private func showAppropriateUserInterface() {
        if self.authService.isAuthorized {
            self.viewController?.showProfile()
        } else {
            self.viewController?.showAuthorization()
        }
    }

    private func image(for client: PrimePassClient?) -> UIImage? {
        client?.photo?.asImage ?? #imageLiteral(resourceName: "user-image")
    }

    @objc
    private func logout() {
        self.authService.removeAuthorization()
        self.clientService.removeClient()

        self.viewController?.setProfileImage(.unauthorized)
        self.viewController?.showAuthorization()
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.loadClient),
            name: .clientUpdated,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.logout),
            name: .logout,
            object: nil
        )
        if PGCMain.shared.featureFlags.profile.shouldUpdateActiveBookingsCount {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.updateActiveBookingsCount),
                name: .didCancelBooking,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.updateActiveBookingsCount),
                name: .newBooking,
                object: nil
            )
        }
        Notification.onReceive(.login) { [weak self] _ in
            self?.showAppropriateUserInterface()
        }
    }
}
