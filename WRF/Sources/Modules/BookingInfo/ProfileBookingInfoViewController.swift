import SafariServices
import SnapKit
import UIKit

protocol ProfileBookingInfoCancelDelegate: AnyObject {
    func bookingCancelled()
}

protocol ProfileBookingInfoViewControllerProtocol: BlockingLoaderPresentable {
    func set(booking: BookingInfoViewModel)
    func showCancelResult(success: Bool)
}

final class ProfileBookingInfoViewController: UIViewController {
    let presenter: ProfileBookingInfoPresenterProtocol

    weak var cancelDelegate: ProfileBookingInfoCancelDelegate?

    private var viewModel: BookingInfoViewModel?
    private let restaurant: Restaurant

    var bookingPresentator: ProfileBookingInfoControllerPresentatorProtocol?

    private lazy var feedbackPresentationManager = FloatingControllerPresentationManager(
        context: .feedback,
        groupID: ProfileBookingViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: .light
    )

    private lazy var menuPresentationManager = FloatingControllerPresentationManager(
        context: .menu,
        groupID: ProfileBookingViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: .light
    )

    private lazy var headerView: RestaurantHeaderView = {
        let view = RestaurantHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.snp.makeConstraints { make in
            make.height.equalTo(self.bookingView.appearance.headerHeight)
        }
        return view
    }()

    private lazy var checkoutSummaryView = CheckoutSummaryView()
    private lazy var bookingInfoActionView: ProfileBookingInfoActionView = {
        let menu = self.restaurant.menu ?? ""
        return ProfileBookingInfoActionView(withMenu: !menu.isEmpty)
    }()

    private lazy var restaurantReviewsView: RestaurantReviewsView = {
        let appearance = RestaurantReviewsView.Appearance(
            insets: self.bookingView.appearance.reviewsInsets
        )
        return RestaurantReviewsView(appearance: appearance)
    }()

    init(
        restaurant: Restaurant,
        presenter: ProfileBookingInfoPresenterProtocol
    ) {
        self.restaurant = restaurant
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	private(set) lazy var bookingView = ProfileBookingInfoView(frame: UIScreen.main.bounds)

	override func loadView() {
		self.view = self.bookingView
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.bookingView.delegate = self

        self.presenter.loadBooking()

        self.bookingView.scrollView.delegate = self

        self.bookingView.addRowView(self.headerView)
        self.bookingView.addRowView(self.checkoutSummaryView)

        let locationsController = RestaurantLocationAssembly(restaurant: self.restaurant).makeModule()
        self.addChild(locationsController)
        self.bookingView.addRowView(locationsController.view)

        self.bookingView.addRowView(self.restaurantReviewsView)
        self.restaurantReviewsView.isHidden = true

        self.bookingView.addRowView(self.bookingInfoActionView)
        self.bookingInfoActionView.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardDidShow),
            name: UIApplication.keyboardDidShowNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private API

    @objc
    private func keyboardDidShow() {
        self.feedbackPresentationManager.move(to: .full)
    }
}

extension ProfileBookingInfoViewController: ProfileBookingInfoViewControllerProtocol {
    func set(booking: BookingInfoViewModel) {
        self.viewModel = booking

        self.headerView.title = booking.title
        self.headerView.address = booking.address
        self.headerView.imageURL = booking.imageURL
        self.headerView.price = booking.price
        self.headerView.distance = booking.distanceText

        self.headerView.isRatingHidden = booking.rating == 0
        self.headerView.rating = booking.rating
        self.headerView.ratingText = booking.assessmentsCountText

        self.checkoutSummaryView.guestsText = booking.booking.guests
        self.checkoutSummaryView.dateText = booking.booking.date
        self.checkoutSummaryView.timeText = booking.booking.time

        if let reviewRating = booking.reviewRating {
            self.restaurantReviewsView.rate = reviewRating.reviewsRating
            self.restaurantReviewsView.totalCount = reviewRating.reviewsTotal
            self.restaurantReviewsView.isHidden = false
        }

        self.bookingView.restaurantName = booking.title
        self.bookingInfoActionView.isCancelEnabled = booking.isCancellable
		self.bookingInfoActionView.isCancelBlocked = false //!booking.isMobileOriginated
        self.bookingInfoActionView.cancelButtonTitle = booking.cancelTitle

        self.bookingPresentator?.updateHeight(
            withRating: booking.reviewRating != nil,
            withCancel: booking.isCancellable
        )
    }

    func showCancelResult(success: Bool) {
        if success {
            self.cancelDelegate?.bookingCancelled()
            self.fp_dismiss(animated: true)
        }
    }
}

extension ProfileBookingInfoViewController: ProfileBookingInfoActionViewDelegate {
    func profileBookingInfoViewDidClickMenu(_ view: ProfileBookingInfoActionView) {
        guard let menu = self.restaurant.menu,
              let menuURL = URL(string: menu) else {
            return
        }
        let controller = SFSafariViewController(url: menuURL)
        self.menuPresentationManager.contentViewController = controller
        self.menuPresentationManager.present()
    }

    func profileBookingInfoViewDidClickFeedback(_ view: ProfileBookingInfoActionView) {
        guard let restaurantID = self.viewModel?.primePassID, let placeName = self.viewModel?.title else {
            return
        }

        let feedbackController = FeedbackAssembly(placeName: placeName, restaurantID: restaurantID).makeModule()
        self.feedbackPresentationManager.contentViewController = feedbackController
        self.feedbackPresentationManager.present()

        // TODO: extract scrollView getter through assembly
        if let feedbackViewController = feedbackController as? FeedbackViewController,
            let trackedScrollView = feedbackViewController.feedbackView?.scrollView {
            self.feedbackPresentationManager.track(scrollView: trackedScrollView)
        }
    }

    func profileBookingInfoViewDidClickCancel(_ view: ProfileBookingInfoActionView) {
        self.bookingView.showCancel = true
    }
}

extension ProfileBookingInfoViewController: ProfileBookingInfoViewDelegate {
    func viewDidRequestBookingCancel() {
        self.presenter.cancelBooking()
    }
}

extension ProfileBookingInfoViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.bookingView.scrollView else {
            return
        }

        // Disable top bounce, 100pt - is just small magic gap
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
}
