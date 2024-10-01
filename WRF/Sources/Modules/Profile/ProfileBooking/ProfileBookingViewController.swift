import UIKit

protocol ProfileBookingViewControllerProtocol: AnyObject {
    func set(bookings: [SectionViewModel])
    func show(booking: HostessBooking, restaurant: Restaurant)
}

final class ProfileBookingViewController: UIViewController {
    static let floatingControllerGroupID = "booking"

    let presenter: ProfileBookingPresenterProtocol
    lazy var bookingView = self.view as? ProfileBookingView

    private var selectedBookingID: HostessBooking.IDType?

    private lazy var bookingInfoPresentationManager = FloatingControllerPresentationManager(
        context: .booking(withRating: false, withCancel: false),
        groupID: ProfileBookingViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private var bookings: [SectionViewModel] = []

    init(presenter: ProfileBookingPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = ProfileBookingView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.loadBookings()
    }
}

extension ProfileBookingViewController: ProfileBookingViewDelegate {
    func bookingViewDidRequestDeliveryLoad() {
//        self.presenter.didTapOnDeliveryTab()
//        let controller = WebFrameAssembly(frameData: .deliveries).makeModule()
//        controller.modalPresentationStyle = .fullScreen
//        self.present(controller, animated: true, completion: nil)
    }

    func bookingViewDidRequestRestaurantsLoad() {
    }
}

extension ProfileBookingViewController: ProfileBookingViewControllerProtocol {
    func set(bookings: [SectionViewModel]) {
        self.bookings = bookings
        self.bookingView?.showEmptyView = self.bookings.isEmpty
        self.bookingView?.updateTableView(delegate: self, dataSource: self)
    }

    func show(booking: HostessBooking, restaurant: Restaurant) {
        let controller = ProfileBookingInfoAssembly(booking: booking, restaurant: restaurant).makeModule()
        if let bookingInfoController = controller as? ProfileBookingInfoViewController {
            bookingInfoController.bookingPresentator = ProfileBookingInfoControllerPresentator(
                manager: self.bookingInfoPresentationManager
            )
            bookingInfoController.cancelDelegate = self
            self.bookingInfoPresentationManager.track(
                scrollView: bookingInfoController.bookingView.scrollView
            )
            self.bookingInfoPresentationManager.contentViewController = bookingInfoController
            self.bookingInfoPresentationManager.present()
        }
    }
}

extension ProfileBookingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.bookingView?.makeSectionLabel(
            self.bookings[section].name
        )
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.bookingView?.appearance.bookingSectionHeight ?? -1
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension ProfileBookingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookings[section].bookings.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileBookingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        if let section = self.bookings[safe: indexPath.section],
           let item = section.bookings[safe: indexPath.row] {
            cell.configure(with: item)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.bookingView?.appearance.bookingItemHeight ?? -1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if let bookings = self.bookings[safe: indexPath.section]?.bookings,
           let booking = bookings[safe: indexPath.row] {
            self.selectedBookingID = booking.id
            self.presenter.select(id: booking.id)
        }
    }
}

extension ProfileBookingViewController: ProfileBookingInfoCancelDelegate {
    func bookingCancelled() {
        guard let bookingID = self.selectedBookingID else {
            return
        }
        self.presenter.reloadBookings(canceling: bookingID)
    }
}

extension ProfileBookingViewController: BookingDeeplinkRoutable {
    var nextStoryRoutable: BookingDeeplinkRoutable? {
        return nil
    }

    func route(bookingID: HostessBooking.IDType) {
        self.presenter.requestBooking(id: bookingID)
    }
}
