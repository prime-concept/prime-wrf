import SafariServices
import UIKit

protocol SearchEventViewControllerProtocol: BlockingLoaderPresentable {
    func set(events: [[SearchEventViewModel]])
    func set(index: Int, event: [SearchEventViewModel])
    func set(eventsCount: Int)

    func set(tags: [SearchEventTagViewModel])
    func set(state: SearchEventView.State)

    func append(events: [[SearchEventViewModel]])

    func present(event: Event)
}

final class SearchEventViewController: UIViewController, ScrollTrackable {
    let presenter: SearchEventPresenterProtocol
    private lazy var searchEventView = self.view as? SearchEventView

    weak var delegate: SearchViewControllerDelegate?

    private var tags: [SearchEventTagViewModel] = []
    private var events: [[SearchEventViewModel]] = []

    private lazy var eventPresentationManager = FloatingControllerPresentationManager(
        context: .event,
        groupID: SearchViewController.floatingControllerGroupID,
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

    var scrollView: UIScrollView? {
        return self.searchEventView?.eventsCollectionView
    }

    init(presenter: SearchEventPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = SearchEventView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.loadEvents()
    }
}

extension SearchEventViewController: SearchEventViewControllerProtocol {
    func set(events: [[SearchEventViewModel]]) {
        self.events = events
        self.searchEventView?.updateEventsCollectionView(delegate: self, dataSource: self)
    }

    func set(index: Int, event: [SearchEventViewModel]) {
        let indexPath = IndexPath(row: index, section: 0)
        self.events[index] = event
        self.searchEventView?.eventsCollectionView.reloadItems(at: [indexPath])
    }

    func set(eventsCount: Int) {
        self.delegate?.updateEventsCount(count: eventsCount)
    }

    func set(tags: [SearchEventTagViewModel]) {
        self.tags = tags
        searchEventView?.setupTagsCollectionView(hidden: tags.isEmpty)
        searchEventView?.updateCategoriesCollectionView(delegate: self, dataSource: self)
    }

    func set(state: SearchEventView.State) {
        self.searchEventView?.state = state
    }

    func append(events: [[SearchEventViewModel]]) {
        var lastRow = self.events.count - 1
        let indexes: [IndexPath] = events.map { _ in
            lastRow += 1
            return IndexPath(row: lastRow, section: 0)
        }
        self.events.append(contentsOf: events)
        self.searchEventView?.eventsCollectionView.insertItems(at: indexes)
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
}

extension SearchEventViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == self.searchEventView?.tagsCollectionView {
            let view = SubtitleTagItemView()
            view.title = self.tags[indexPath.row].title
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setNeedsLayout()
            view.layoutIfNeeded()

            let height = self.searchEventView?.appearance.categoryItemHeight ?? 0
            return CGSize(width: view.bounds.width, height: height)
        }
        return CGSize(
            width: UIScreen.main.bounds.width,
            height: self.searchEventView?.appearance.itemHeight ?? 1
        )
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let tag = self.tags[safe: indexPath.row] {
            self.presenter.select(tag: tag.id)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.childDidScroll()
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard collectionView != self.searchEventView?.tagsCollectionView,
              (self.events.count - 1) == indexPath.row else {
            return
        }
        self.presenter.loadNextEvents()
    }
}

extension SearchEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.searchEventView?.tagsCollectionView {
            return self.tags.count
        }
        return self.events.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == self.searchEventView?.tagsCollectionView {
            let tag = self.tags[indexPath.row]
            let cell: SearchEventTagCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: tag)
            return cell
        }
        let cell: SearchEventMultiCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.delegate = self
        cell.items = self.events[indexPath.row]
        return cell
    }
}

extension SearchEventViewController: SearchEventMultiCollectionViewCellDelegate {
    func searchEventMultipleCollectionViewCell(
        _ cell: SearchEventMultiCollectionViewCell,
        didFavorite model: SearchEventViewModel
    ) {
        self.presenter.update(event: model)
    }

    func searchEventMultipleCollectionViewCell(didSelect model: SearchEventViewModel) {
        self.presenter.select(event: model.id)
    }
}
