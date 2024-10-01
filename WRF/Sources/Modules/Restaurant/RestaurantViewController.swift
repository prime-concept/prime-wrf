import SafariServices
import UIKit

protocol RestaurantViewControllerProtocol: AnyObject {
    func set(restaurant: RestaurantViewModel)
    func set(isFavorite: Bool)
    
    func present(event: Event)
    func handleUnauthorizedUser()
}

final class RestaurantViewController: UIViewController {
    static let floatingControllerGroupID = "restaurant"
    private static let bottomSpacing: CGFloat = 30.0
    
    let presenter: RestaurantPresenterProtocol
    lazy var restaurantView = self.view as? RestaurantView
    
    private var viewModel: RestaurantViewModel?
    private let primePassID: PrimePassRestaurantIDType
    private let hostessScheduleKey: String
    private let restaurant: Restaurant
    
    private var cachedBookingAvailability = false
    private var canReserveByPhone = true
    private var isOnceDragingReviews = false //For sending analytics event onc for "reviews" collection draging.
    
    private lazy var eventPresentationManager = FloatingControllerPresentationManager(
        context: .event,
        sourceViewController: self
    )
    
    private lazy var eventWebPresentationManager = FloatingControllerPresentationManager(
        context: .eventWeb,
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: .light
    )
    
    // Content views
    private lazy var locationsController = RestaurantLocationAssembly(restaurant: self.restaurant).makeModule()
    
    private lazy var bookingViewController = RestaurantBookingAssembly(
        restaurantPrimePassID: self.primePassID,
        hostessScheduleKey: hostessScheduleKey,
        menu: self.restaurant.menu,
        restaurantId: self.restaurant.id,
        restaurantName: self.restaurant.title,
        moduleOutput: self
    ).makeModule()
    
    private lazy var unavailableView = RestaurantUnavailableView()
    
    private lazy var deliveryButtonView = RestaurantDeliveryButtonView()
    
    private lazy var menuButtonView = RestaurantMenuButtonView()
    
    private lazy var actionView = RestaurantBookingActionContainerView()
    
    private lazy var descriptionView = RestaurantDescriptionView()
    
    private lazy var shareView = RestaurantShareView()
    
    private lazy var eventsView = RestaurantEventsView()
    
    private lazy var likesView = RestaurantLikesView()
    
    private lazy var reviewsView = RestaurantReviewsView()
    
    private lazy var contactsView = RestaurantContactsView()
    
    private lazy var photosView = RestaurantPhotosView()
    
    private lazy var tagsView = RestaurantTagsView()
    
    var restaurantControllerPresentator: RestaurantControllerPresentatorProtocol?
    
    init(
        restaurantID: PrimePassRestaurantIDType,
        hostessScheduleKey: String,
        restaurant: Restaurant,
        presenter: RestaurantPresenterProtocol
    ) {
        self.primePassID = restaurantID
        self.hostessScheduleKey = hostessScheduleKey
        self.restaurant = restaurant
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = RestaurantView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restaurantView?.scrollView.delegate = self
        self.restaurantView?.delegate = self
        
        self.contactsView.delegate = self
        self.unavailableView.delegate = self
        self.actionView.delegate = self
        
        self.presenter.loadRestaurant()
        
        // Booking
        self.addChild(self.bookingViewController)
        self.bookingViewController.view.isHidden = true
        self.restaurantView?.addRowView(self.bookingViewController.view)
        
        self.restaurantView?.addRowView(self.unavailableView)
        self.unavailableView.isHidden = true
        
        self.restaurantView?.addRowView(self.menuButtonView)
        self.menuButtonView.isHidden = true
        
        self.restaurantView?.addRowView(self.actionView)
        self.actionView.isHidden = true
        
        self.restaurantView?.addRowView(self.deliveryButtonView)
        self.deliveryButtonView.isHidden = true
        
        // Content
        self.restaurantView?.addRowView(self.descriptionView)
        self.descriptionView.isHidden = true
        
        self.restaurantView?.addRowView(self.tagsView)
        self.tagsView.isHidden = true
        
        self.restaurantView?.addRowView(self.photosView)
        self.photosView.isHidden = true
        
        self.restaurantView?.addRowView(self.shareView)
        self.shareView.isHidden = true
        
        self.restaurantView?.addRowView(self.eventsView)
        self.eventsView.isHidden = true
        
        self.restaurantView?.addRowView(self.likesView)
        self.likesView.isHidden = true
        
        self.restaurantView?.addRowView(self.reviewsView)
        self.reviewsView.isHidden = true
        
        self.addChild(self.locationsController)
        self.restaurantView?.addRowView(self.locationsController.view)
        self.locationsController.view.isHidden = true
        
        self.restaurantView?.addRowView(self.contactsView)
        self.contactsView.isHidden = true
        
        self.restaurantView?.addRowView(RestaurantSpacingView(height: type(of: self).bottomSpacing))
        
        // Delegates
        self.eventsView.updateCollectionView(delegate: self, dataSource: self)
        self.reviewsView.updateCollectionView(delegate: self, dataSource: self)
        self.photosView.updateCollectionView(delegate: self, dataSource: self)
    }
    
    // MARK: - Private API
    
    private func showAuthorization() {
        let moduleController = AuthAssembly().makeModule()
        self.present(moduleController, animated: true)
    }
    
    private func makeCall(phone: String?) {
        guard let phone = phone?.filter({ "+01234567890".contains($0) }),
              let url = URL(string: "tel:\(phone)") else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showDelivery(restaurantID: String) {
        let controller = WebFrameAssembly(frameData: .restaurant(id: restaurantID)).makeModule()
        controller.modalPresentationStyle = .fullScreen
        
        self.present(controller, animated: true)
    }
    
    private lazy var menuPresentationManager = FloatingControllerPresentationManager(
        context: .menu,
        groupID: RestaurantViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: nil
    )
    
    private func showMenu(menu: String) {
        guard let menuURL = URL(string: menu) else {
            return
        }
        let controller = SFSafariViewController(url: menuURL)
        self.menuPresentationManager.contentViewController = controller
        self.menuPresentationManager.present()
    }
}

extension RestaurantViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.restaurantView?.scrollView else {
            return
        }
        
        // Disable top bounce, 100pt - is just small magic gap
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
}

extension RestaurantViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.eventsView.collectionView {
            return self.viewModel?.events.count ?? 0
        }
        
        if collectionView == self.reviewsView.collectionView {
            return self.viewModel?.reviews.count ?? 0
        }
        
        if collectionView == self.photosView.collectionView {
            return self.viewModel?.images.count ?? 0
        }
        
        fatalError("Unsupported collection view")
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == self.eventsView.collectionView {
            let cell: RestaurantEventCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let viewModel = self.viewModel?.events[safe: indexPath.row] {
                cell.configure(with: viewModel)
            }
            return cell
        }
        
        if collectionView == self.reviewsView.collectionView {
            let cell: RestaurantReviewCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let viewModel = self.viewModel?.reviews[safe: indexPath.row] {
                cell.configure(with: viewModel)
            }
            return cell
        }
        
        if collectionView == self.photosView.collectionView {
            let cell: RestaurantPhotoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            
            if let photo = self.viewModel?.images[safe: indexPath.row] {
                cell.configure(with: photo.image)
            }
            return cell
        }
        
        fatalError("Unsupported collection view")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.eventsView.collectionView {
            self.presenter.requestEventPresentation(position: indexPath.row)
        } else if collectionView == self.photosView.collectionView {
            let photosController = PhotosAssembly(
                restaurant: self.restaurant,
                selectedIndex: indexPath.row
            ).makeModule()
            
            self.presenter.didTapOnPhotoGallery()
            photosController.modalPresentationStyle = .fullScreen
            
            self.present(photosController, animated: true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.tag == 1 && self.isOnceDragingReviews == false {
            self.presenter.didScrollRestaurantReviews()
            self.isOnceDragingReviews = true
        }
    }
}

extension RestaurantViewController: RestaurantViewControllerProtocol {
    func set(restaurant: RestaurantViewModel) {
        self.viewModel = restaurant
        self.restaurantView?.configure(with: restaurant)
        
        updateBookingAvailability(isAvailable: cachedBookingAvailability)
        
        if let menu = restaurant.menu, !menu.isEmpty && !cachedBookingAvailability, !self.canReserveByPhone {
            self.menuButtonView.isHidden = false
            self.menuButtonView.onButtonClick = { [weak self] in
                self?.showMenu(menu: menu)
            }
        } else {
            self.menuButtonView.isHidden = true
        }
        
        if let deliveryFrameID = restaurant.deliveryFrameID {
            self.deliveryButtonView.isHidden = false
            self.deliveryButtonView.onButtonClick = { [weak self] in
                self?.presenter.didTapOnDeliveryButton()
                self?.showDelivery(restaurantID: deliveryFrameID)
            }
        } else {
            self.deliveryButtonView.isHidden = true
        }
        
        if let description = restaurant.description {
            self.descriptionView.text = description
            self.descriptionView.isHidden = false
        }
        
        if !restaurant.images.isEmpty {
            self.photosView.updateCollectionView(delegate: self, dataSource: self)
            self.photosView.isHidden = false
        }
        
        if !restaurant.events.isEmpty {
            self.eventsView.updateCollectionView(delegate: self, dataSource: self)
            self.eventsView.isHidden = false
        }
        
        if !restaurant.tags.isEmpty {
            self.tagsView.update(tags: restaurant.tags)
            self.tagsView.isHidden = false
        }
        
        if !restaurant.reviews.isEmpty {
            self.reviewsView.rate = restaurant.ratingFloat
            self.reviewsView.totalCount = restaurant.assessmentsCount
            
            self.reviewsView.updateCollectionView(delegate: self, dataSource: self)
            self.reviewsView.isHidden = false
            
            // Likes
            self.likesView.isHidden = false
            self.likesView.displayingAvatars = restaurant.reviews.map { $0.userImage }
            self.likesView.displayingInfo = (restaurant.reviews[0].userName, restaurant.reviews.count)
        }
        
        if let workingTime = restaurant.workingTime {
            self.contactsView.daysText = workingTime.days
            self.contactsView.timeText = workingTime.hours
            
            self.unavailableView.daysText = workingTime.days
            self.unavailableView.timeText = workingTime.hours
        }
        
        if let phone = restaurant.phone, let site = restaurant.site {
            self.contactsView.phone = phone
            self.contactsView.site = site
            self.contactsView.isHidden = false
        }
        
        if restaurant.address != nil {
            self.locationsController.view.isHidden = false
        }
    }
    
    func set(isFavorite: Bool) {
        guard var viewModel = self.viewModel else {
            return
        }
        viewModel.isFavorite = isFavorite
        self.viewModel = viewModel
        
        self.restaurantView?.configure(with: viewModel)
    }
    
    func present(event: Event) {
        if let url = URL(string: event.partnerLink ?? "") {
            self.eventWebPresentationManager.contentViewController = SFSafariViewController(url: url)
            self.eventWebPresentationManager.present()
        } else {
            let assembly = EventAssembly(event: event)
            
            self.eventPresentationManager.contentViewController = assembly.makeModule()
            self.eventPresentationManager.present()
            
            if let trackedScrollView = assembly.trackedScrollView {
                self.eventPresentationManager.track(scrollView: trackedScrollView)
            }
        }
    }
    
    func handleUnauthorizedUser() {
        self.showAuthorization()
    }
}

extension RestaurantViewController: RestaurantBookingModuleOutput {
    func requestPhoneCall() {
        self.presenter.didCallRestaurantForBooking()
        self.makeCall(phone: self.viewModel?.phone)
    }
    
    func updatePosition(withConfirmation: Bool, withDeposit: Bool, withComment: Bool) {
        self.restaurantControllerPresentator?.updateHeight(
            withConfirmation: withConfirmation,
            withDeposit: withDeposit,
            withComment: withComment
        )
    }
    
    func updateBookingAvailability(isAvailable: Bool) {
        self.cachedBookingAvailability = isAvailable
        if self.viewModel?.isClosed == true {
            self.unavailableView.isHidden = true
            self.bookingViewController.view.isHidden = true
            
            return
        }
        
        if isAvailable {
            self.bookingViewController.view.isHidden = false
            self.unavailableView.isHidden = true
            self.menuButtonView.isHidden = true
            self.actionView.isHidden = true
        } else {
            if let workingTime = self.viewModel?.workingTime {
                self.unavailableView.daysText = workingTime.days
                self.unavailableView.timeText = workingTime.hours
            }
            
            let canReserveByPhone = self.viewModel?.canReserve == true
            
            self.bookingViewController.view.isHidden = true
            self.unavailableView.isHidden = !canReserveByPhone
            
            self.canReserveByPhone = canReserveByPhone
            if canReserveByPhone {
                if let menu = self.viewModel?.menu, !menu.isEmpty {
                    self.unavailableView.setBookingButtonVisibility(false)
                    self.actionView.isHidden = false
                } else {
                    self.unavailableView.setBookingButtonVisibility(true)
                    self.actionView.isHidden = true
                }
            }
        }
    }
    
    func requestUserAuthorization() {
        self.showAuthorization()
    }
}

extension RestaurantViewController: RestaurantViewDelegate {
    func restaurantViewDidShare(_ view: RestaurantView) {
        self.presenter.share()
    }
    
    func restaurantViewDidRequestPanorama(_ view: RestaurantView) {
        guard let viewModel = self.viewModel?.panorama else {
            return
        }
        
        let panoramaAssembly = PanoramaAssembly(seed: PanoramaSeed(images: viewModel.images))
        self.present(panoramaAssembly.makeModule(), animated: true)
    }
    
    func restaurantViewDidFavorite(_ view: RestaurantView) {
        guard let viewModel = self.viewModel,
              let isFavorite = viewModel.isFavorite else {
            return
        }
        self.presenter.updateFavoriteStatus(isFavorite: isFavorite)
    }
}

extension RestaurantViewController: RestaurantContactsViewDelegate {
    func restaurantContactsViewDidRequestLinkOpen(_ view: RestaurantContactsView) {
        guard let site = self.viewModel?.site, let url = URL(string: site) else {
            return
        }
        
        self.presenter.didTapOnOpenWebpage()
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func restaurantContactsViewDidRequestPhoneCall(_ view: RestaurantContactsView) {
        self.presenter.didCallRestaurantForInfo()
        self.makeCall(phone: self.viewModel?.phone)
    }
}

extension RestaurantViewController: RestaurantUnavailableViewDelegate {
    func restaurantUnavailableViewDidRequestCall(_ view: RestaurantUnavailableView) {
        self.makeCall(phone: self.viewModel?.phone)
    }
}

extension RestaurantViewController: RestaurantBookingActionContainerViewDelegate {
    func restaurantBookingActionContainerViewDidRequestCall(_ view: RestaurantBookingActionContainerView) {
        self.makeCall(phone: self.viewModel?.phone)
    }
    
    func restaurantBookingActionContainerViewDidOpenMenu(_ view: RestaurantBookingActionContainerView) {
        self.showMenu(menu: self.viewModel?.menu ?? "")
    }
}
