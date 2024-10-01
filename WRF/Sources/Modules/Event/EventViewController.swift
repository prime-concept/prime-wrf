import UIKit

protocol EventViewControllerProtocol: AnyObject {
    func set(event: EventViewModel)
    func present(restaurant: Restaurant)
}

final class EventViewController: UIViewController {
    let presenter: EventPresenterProtocol
    lazy var eventView = self.view as? EventView

    private var participants: [EventViewModel.Participant] = []

    private lazy var restaurantPresentationManager = FloatingControllerPresentationManager(
        context: .restaurant(withConfirmation: false, withDeposit: false, withComment: false),
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self
    )

    init(presenter: EventPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = EventView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventView?.scrollView.delegate = self
        self.eventView?.participantsView.updateCollectionView(delegate: self, dataSource: self)

        self.presenter.loadEvent()
    }
}

extension EventViewController: EventViewControllerProtocol {
    func set(event: EventViewModel) {
        self.participants = event.participants

        self.eventView?.update(with: event)
        self.eventView?.participantsView.isHidden = event.participants.isEmpty

        self.eventView?.setNeedsLayout()
        self.eventView?.layoutIfNeeded()

        self.eventView?.participantsView.updateCollectionView(delegate: self, dataSource: self)
    }

    func present(restaurant: Restaurant) {
        let restaurantController = RestaurantAssembly(restaurant: restaurant).makeModule()
        self.restaurantPresentationManager.contentViewController = restaurantController
        self.restaurantPresentationManager.present()

        // TODO: extract scrollView getter through assembly
        if let restaurantViewController = restaurantController as? RestaurantViewController,
           let trackedScrollView = restaurantViewController.restaurantView?.scrollView {
            restaurantViewController.restaurantControllerPresentator = RestaurantControllerPresentator(
                manager: self.restaurantPresentationManager
            )
            self.restaurantPresentationManager.track(scrollView: trackedScrollView)
        }
    }
}

extension EventViewController: EventViewDelegate {
    func eventViewDidRequestFavoriteStatusUpdate(_ view: EventView) {
        self.presenter.updateFavoriteStatus()
    }

    func eventViewDidRequestShare(_ view: EventView) {
        self.presenter.share()
    }
}

extension EventViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.eventView?.scrollView else {
            return
        }

        // Disable top bounce, 100pt - is just small magic gap
        scrollView.bounces = scrollView.contentOffset.y > 100
    }
}

extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.participants.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: EventParticipantCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        let model = self.participants[indexPath.row]
        cell.configure(with: model)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.participants[safe: indexPath.row] {
            self.presenter.select(participant: model)
        }
    }
}
