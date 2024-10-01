import SafariServices
import UIKit
import YoutubeKit

protocol EventsViewControllerProtocol: BlockingLoaderPresentable {
    func set(events: [[EventItemViewModel]])
    func set(tags: [EventTagViewModel])
    func set(index: Int, event: [EventItemViewModel])

    func append(events: [[EventItemViewModel]])

    func present(event: Event)

    func openFirstVideo()
}

final class EventsViewController: UIViewController, BlockingLoaderPresentable {
    static let floatingControllerGroupID = "events"

    let presenter: EventsPresenterProtocol
    lazy var eventsView = self.view as? EventsView

    private var videoPlayer: YTSwiftyPlayer?
    private var previousState: YTSwiftyPlayerState?

    private lazy var eventPresentationManager = FloatingControllerPresentationManager(
        context: .event,
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private lazy var eventWebPresentationManager = FloatingControllerPresentationManager(
        context: .eventWeb,
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self,
        shouldMinimizePreviousController: true,
        grabberAppearance: .light
    )

    private lazy var searchPresentationManager = FloatingControllerPresentationManager(
        context: .search(height: SearchViewController.Appearance.controllerHeight),
        groupID: EventsViewController.floatingControllerGroupID,
        sourceViewController: self,
        grabberAppearance: .light
    )

    private var events: [[EventItemViewModel]] = []
    private var tags: [EventTagViewModel] = []

    init(presenter: EventsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = EventsView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "События"

        let calendarBarButton = UIBarButtonItem(
            image: #imageLiteral(resourceName: "events-search-bar-button"),
            style: .plain,
            target: self,
            action: #selector(self.showSearch)
        )
        self.navigationItem.setRightBarButton(calendarBarButton, animated: false)

        self.eventsView?.updateCategoriesCollectionView(delegate: self, dataSource: self)
        self.eventsView?.updateEventsCollectionView(delegate: self, dataSource: self)

        self.presenter.loadEvents()
    }

    // MARK: - Private API

    @objc
    private func showSearch() {
        let searchController = SearchAssembly(page: .events).makeModule()
        self.searchPresentationManager.contentViewController = searchController
        self.searchPresentationManager.present()

        if let searchViewController = searchController as? SearchViewController {
            searchViewController.searchControllerPresentator = SearchControllerPresentator(
                manager: self.searchPresentationManager
            )
        }
    }

    private func initPlayer(videoID: String) {
        self.videoPlayer.flatMap { $0.removeFromSuperview() }

        let player = YTSwiftyPlayer(
            playerVars: [
                .videoID(videoID),
                .playsInline(false),
                .showFullScreenButton(false),
                .autoplay(true),
                .showRelatedVideo(false)
            ]
        )

        self.previousState = nil
        self.videoPlayer = player

        player.delegate = self

        self.view.addSubview(player)
        player.snp.makeConstraints { make in
            make.size.equalTo(CGSize.zero)
        }

        self.showLoading()
        player.loadPlayer()
    }
}

extension EventsViewController: EventsViewControllerProtocol {
    func set(events: [[EventItemViewModel]]) {
        self.events = events
        self.eventsView?.showEmptyView = events.isEmpty
        self.eventsView?.updateEventsCollectionView(delegate: self, dataSource: self)
    }

    func set(tags: [EventTagViewModel]) {
        self.tags = tags
        self.eventsView?.updateCategoriesCollectionView(delegate: self, dataSource: self)
    }

    func set(index: Int, event: [EventItemViewModel]) {
        let indexPath = IndexPath(row: index, section: 0)
        self.events[index] = event
        self.eventsView?.eventsCollectionView.reloadItems(at: [indexPath])
    }

    func append(events: [[EventItemViewModel]]) {
        var lastRow = self.events.count - 1
        let indexes: [IndexPath] = events.map { _ in
            lastRow += 1
            return IndexPath(row: lastRow, section: 0)
        }
        self.events.append(contentsOf: events)
        self.eventsView?.eventsCollectionView.insertItems(at: indexes)
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

    func openFirstVideo() {
        guard
            let videos = self.events.first,
            let firstVideo = videos.first,
            let videoInfo = firstVideo.videoInfo
        else {
            return
        }

        self.initPlayer(videoID: videoInfo.videoID)
    }
}

extension EventsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == self.eventsView?.tagsCollectionView {
            let view = SubtitleTagItemView()
            view.title = self.tags[indexPath.row].title
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setNeedsLayout()
            view.layoutIfNeeded()

            let height = self.eventsView?.appearance.categoryItemHeight ?? 0
            return CGSize(width: view.bounds.width, height: height)
        }

        if self.events[safe: indexPath.row]?.first?.videoInfo != nil {
            return CGSize(
                width: UIScreen.main.bounds.width,
                height: self.eventsView?.appearance.videoEventItemHeight ?? 0
            )
        }

        return CGSize(
            width: UIScreen.main.bounds.width,
            height: self.eventsView?.appearance.eventItemHeight ?? 0
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard (self.events.count - 1) == indexPath.row else {
            return
        }
        self.presenter.loadNextEvents()
    }
}

extension EventsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.eventsView?.tagsCollectionView {
            return self.tags.count
        }
        return self.events.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == self.eventsView?.tagsCollectionView else {
            return
        }
        let tag = self.tags[indexPath.row]
        self.presenter.selectTag(id: tag.id)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == self.eventsView?.tagsCollectionView {
            let tag = self.tags[indexPath.row]
            let cell: EventTagCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: tag)
            return cell
        }

        let cell: EventMultipleCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        cell.items = self.events[indexPath.row]
        return cell
    }
}

extension EventsViewController: EventMultipleCollectionViewCellDelegate {
    func eventMultipleCollectionViewCell(
        _ cell: EventMultipleCollectionViewCell,
        didSelect event: EventItemViewModel
    ) {
        if let videoInfo = event.videoInfo {
            self.initPlayer(videoID: videoInfo.videoID)
        } else {
            self.presenter.selectEvent(id: event.id)
        }
    }

    func eventMultipleCollectionViewCell(
        _ cell: EventMultipleCollectionViewCell,
        didFavorite event: EventItemViewModel
    ) {
        self.presenter.updateFavoriteStatus(id: event.id, isFavorite: event.isFavorite)
    }

    func eventMultipleCollectionViewCell(_ cell: EventMultipleCollectionViewCell, didShare event: EventItemViewModel) {
        guard let videoURL = event.videoInfo?.videoURL else {
            return
        }

        let items = [videoURL]
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activity, animated: true)
    }
}

extension EventsViewController: YTSwiftyPlayerDelegate {
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        guard let previousState = self.previousState else {
            self.previousState = state
            return
        }

        if previousState == .buffering && state == .paused {
            self.videoPlayer?.playVideo()
        }

        if state == .playing {
            self.hideLoading()
        }

        self.previousState = state
    }

    func player(_ player: YTSwiftyPlayer, didReceiveError error: YTSwiftyPlayerError) {
        self.hideLoading()
    }
}
