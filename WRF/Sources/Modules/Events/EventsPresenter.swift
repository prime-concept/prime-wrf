import CoreLocation
import PromiseKit
import UIKit

extension Notification.Name {
    static let videoStartPlay = Notification.Name(rawValue: "Events.VideoStartPlay")
}

protocol EventsPresenterProtocol {
    func loadEvents()
    func loadNextEvents()

    func selectEvent(id: EventItemViewModel.IDType)
    func selectTag(id: EventTagViewModel.IDType)

    func updateFavoriteStatus(id: Int, isFavorite: Bool)
}

final class EventsPresenter: EventsPresenterProtocol {
    weak var viewController: EventsViewControllerProtocol?

    private let eventsEndpoint: EventsEndpointProtocol
    private let tagsEndpoint: TagsEndpointProtocol
    private let favoritesService: FavoritesServiceProtocol
    private let eventsPersistenceService: EventsPersistenceServiceProtocol
    private let eventListContainerPersistenceService: EventListContainerPersistenceServiceProtocol
    private let youtubeVideosEndpoint: YoutubeVideosEndpointProtocol
    private let youtubeService: YoutubeServiceProtocol

    private let dateFormatter: DateFormatter

    private var response: NavigatorListResponse<Event>?
    private var youtubeResponse: YoutubeAPIVideoResponse?
    private var youtubeVideos: [YoutubeVideo] = []

    private var pageable: Meta?
    private var events: [Event] = []
    private var tags: [Tag] = []

    private var selectedTag: Tag?

    private var shouldOpenFirstVideo = false
    private var didOpenFirstVideo = false

    private var isLoading = false {
        didSet {
            if self.isLoading, !self.events.isEmpty, self.selectedTag != nil {
                self.viewController?.showLoading()
            } else {
                self.viewController?.hideLoading()
            }
        }
    }

    init(
        eventsEndpoint: EventsEndpointProtocol,
        tagsEndpoint: TagsEndpointProtocol,
        favoritesService: FavoritesServiceProtocol,
        eventsPersistenceService: EventsPersistenceServiceProtocol,
        eventListContainerPersistenceService: EventListContainerPersistenceServiceProtocol,
        youtubeVideosEndpoint: YoutubeVideosEndpointProtocol,
        youtubeService: YoutubeServiceProtocol
    ) {
        self.eventsEndpoint = eventsEndpoint
        self.tagsEndpoint = tagsEndpoint
        self.favoritesService = favoritesService
        self.eventsPersistenceService = eventsPersistenceService
        self.eventListContainerPersistenceService = eventListContainerPersistenceService
        self.youtubeVideosEndpoint = youtubeVideosEndpoint
        self.youtubeService = youtubeService

        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        self.dateFormatter = formatter

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resourceFavorited),
            name: .resourceFavorited,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.resourceUnfavorited),
            name: .resourceUnfavorited,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.startVideoPlay),
            name: .videoStartPlay,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    func loadEvents() {
        self.loadCachedEvents()
        self.loadEvents(tag: nil)
    }

    func loadNextEvents() {
        guard let pageable = self.pageable, pageable.hasNext, !self.isLoading else {
            return
        }
        self.isLoading = true
        DispatchQueue.global(qos: .userInitiated).promise {
            self.eventsEndpoint.retrieve(
                page: pageable.next,
                title: nil,
                tag: self.selectedTag?.id,
                date: nil,
                cityID: nil
            ).result
        }.done { response in
            self.pageable = response.pageable
            let eventsCountBeforeUpdate = self.events.count
            self.events.append(contentsOf: response.items)

            let events = response.items.enumerated().compactMap {
                self.makeViewModel(
                    index: $0 + eventsCountBeforeUpdate,
                    event: $1,
                    isFavorite: $1.isFavorite,
                    restaurants: response.dependencies.restaurants
                )
            }
            self.viewController?.append(events: events)
        }.ensure {
            self.isLoading = false
        }.catch { error in
            print("events presenter: error while loading events = \(error)")
        }
    }

    func selectEvent(id: EventItemViewModel.IDType) {
        guard let event = self.events[safe: id] else {
            return
        }
        AnalyticsReportingService.shared.didТapOnNewsFromEvents(eventId: event.id)
        self.viewController?.present(event: event)
    }

    func selectTag(id: EventTagViewModel.IDType) {
        guard let tag = self.tags[safe: id] else {
            return
        }
        self.selectedTag = tag
        self.loadEvents(tag: tag)
    }

    func updateFavoriteStatus(id: Int, isFavorite: Bool) {
        guard let event = self.events[safe: id] else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesService.updateFavoritesStatus(
                resourceID: event.id,
                type: .events,
                isFavorite: isFavorite
            )
        }.catch { error in
            print("events presenter: error when executing favorite status change = \(error)")
        }
    }

    // MARK: - Private API

    private func loadEvents(tag: Tag?) {
        self.isLoading = true

        // swiftlint:disable operator_usage_whitespace

        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.eventsEndpoint.retrieve(
                page: 1,
                title: nil,
                tag: tag?.id,
                date: nil,
                cityID: nil
            ).result
        }.then(on: queue) { response -> Promise<([Event], [Restaurant])> in
            self.response = response
            self.pageable = response.pageable
            return self.saveEvents(tag: tag, events: response.items, restaurants: response.dependencies.restaurants)
        }.then(on: queue) { events, restaurants -> Promise<([Event], [Restaurant], [YoutubeVideo])> in
            if !self.youtubeVideos.isEmpty {
                return Promise<[YoutubeVideo]>.value(self.youtubeVideos)
                    .map { (events, restaurants, $0) }
            }

            return self.youtubeVideosEndpoint.retrieve().result.map { (events, restaurants, $0.items) }
        }.then(on: queue) {
            events, restaurants, videos -> Promise<(
                [Event],
                [Restaurant],
                [YoutubeVideo],
                YoutubeAPIVideoResponse?
            )> in

            self.youtubeVideos = videos

            if let cachedYoutubeResponse = self.youtubeResponse {
                return Promise<YoutubeAPIVideoResponse>.value(cachedYoutubeResponse)
                    .map { (events, restaurants, videos, $0) }
            }

            let videosIDS = videos.map { $0.link }
            return self.youtubeService.loadVideos(ids: videosIDS).map { (events, restaurants, videos, $0) }
        }.then(on: queue) {
            events, restaurants, videos, youtubeResponse -> Promise<(
                [Event],
                [Restaurant],
                [YoutubeVideo],
                YoutubeAPIVideoResponse?,
                [Tag]
            )> in

            self.youtubeResponse = youtubeResponse

            if !self.tags.isEmpty {
                return Promise<[Tag]>.value(self.tags).map { (events, restaurants, videos, youtubeResponse, $0) }
            }
            return self.tagsEndpoint.retrieve().result.map { (events, restaurants, videos, youtubeResponse, $0.events) }
        }.done { events, restaurants, videos, youtubeResponse, tags in
            self.tags = tags
            self.events = events

            let eventViewModels = events.enumerated().compactMap {
                self.makeViewModel(
                    index: $0,
                    event: $1,
                    isFavorite: $1.isFavorite,
                    restaurants: restaurants
                )
            }

            let videoViewModels = self.makeViewModel(youtubeVideos: videos, youtubeResponse: youtubeResponse)

            self.viewController?.set(
                events: videoViewModels.isEmpty
                    ? eventViewModels
                    : [videoViewModels] + eventViewModels
            )
            self.openFirstVideoIfNeeded()

            let tags = tags.enumerated()
                .compactMap { (index, loadedTag) in
                    self.makeViewModel(
                        index: index,
                        tag: loadedTag,
                        eventsWithTags: events.filter { $0.tagsIDs?.contains(loadedTag.id) == true },
                        isSelected: loadedTag.id == tag?.id
                    )
                }
            self.viewController?.set(tags: tags)
        }.ensure {
            self.isLoading = false
        }.catch { error in
            print("events presenter: error while loading events = \(error)")
        }

        // swiftlint:enable operator_usage_whitespace
    }

    private func loadCachedEvents() {
        let queue = DispatchQueue.global(qos: .userInitiated)
        queue.promise {
            self.eventsPersistenceService.retrieve()
        }.then(on: queue) { events -> Promise<[(Event, [Restaurant])]> in
            let promises = events.map { event in
                self.eventListContainerPersistenceService.retrieve(by: event.id).map {
                    (event, $0?.restaurants ?? [])
                }
            }
            return when(fulfilled: promises)
        }.done { result in
            guard !result.isEmpty else {
                return
            }
            self.events = result.map { $0.0 }

            let viewModels = result.enumerated().compactMap { (offset, element) -> [EventItemViewModel] in
            let (event, restaurants) = element
                return self.makeViewModel(
                    index: offset,
                    event: event,
                    isFavorite: event.isFavorite,
                    restaurants: restaurants
                )
            }
            self.viewController?.set(events: viewModels)
        }.cauterize()
    }

    private func saveEvents(
        tag: Tag?,
        events: [Event],
        restaurants: [Restaurant]
    ) -> Promise<([Event], [Restaurant])> {
        guard tag == nil else {
            return Promise.value((events, restaurants))
        }
        return Promise<([Event], [Restaurant])> { seal in
            let containers = events.map { event-> EventListContainer in
                EventListContainer(
                    id: event.id,
                    restaurants: restaurants.filter { event.restaurantsIDs?.contains($0.id) ?? false }
                )
            }
            when(
                fulfilled: [
                    self.eventsPersistenceService.save(events: events),
                    self.eventListContainerPersistenceService.save(containers: containers)
                ]
            ).done { _ in
                seal.fulfill((events, restaurants))
            }.cauterize()
        }
    }

    @objc
    private func resourceFavorited(notification: Notification) {
        guard let resourceId = FavoritesService.extractEventFavorite(from: notification),
            let response = self.response else {
            return
        }
        if let (index, event) = self.events.enumerated().first(where: { $1.id == resourceId }) {
            let model = self.makeModel(from: event, isFavorite: true)
            self.events[index] = model

            let viewModel = self.makeViewModel(
                index: index,
                event: event,
                isFavorite: true,
                restaurants: response.dependencies.restaurants
            )

            let videosOffset = (self.youtubeResponse?.items.count ?? 0) > 0 ? 1 : 0
            self.viewController?.set(index: videosOffset + index, event: viewModel)
        }
    }

    @objc
    private func resourceUnfavorited(notification: Notification) {
        guard let resourceId = FavoritesService.extractEventFavorite(from: notification),
              let response = self.response else {
            return
        }
        if let (index, event) = self.events.enumerated().first(where: { $1.id == resourceId }) {
            let model = self.makeModel(from: event, isFavorite: false)
            self.events[index] = model

            let viewModel = self.makeViewModel(
                index: index,
                event: event,
                isFavorite: false,
                restaurants: response.dependencies.restaurants
            )

            let videosOffset = (self.youtubeResponse?.items.count ?? 0) > 0 ? 1 : 0
            self.viewController?.set(index: videosOffset + index, event: viewModel)
        }
    }

    private func openFirstVideoIfNeeded() {
        guard !self.youtubeVideos.isEmpty else {
            return
        }

        guard !self.didOpenFirstVideo && self.shouldOpenFirstVideo  else {
            return
        }

        self.didOpenFirstVideo.toggle()
        self.shouldOpenFirstVideo.toggle()
        self.viewController?.openFirstVideo()
    }

    @objc
    private func startVideoPlay(notification: Notification) {
        self.shouldOpenFirstVideo = true

        if !self.youtubeVideos.isEmpty {
            self.viewController?.openFirstVideo()
        }
    }

    private func makeViewModel(
        youtubeVideos: [YoutubeVideo],
        youtubeResponse: YoutubeAPIVideoResponse?
    ) -> [EventItemViewModel] {
        return youtubeVideos.enumerated().map { index, video in
            let apiData = youtubeResponse?.items.first(where: { $0.id == video.link })

            return EventItemViewModel(
                id: -1000 + index,
                title: video.title ?? apiData?.snippet.title ?? "",
                isFavorite: false,
                date: nil,
                restaurantTitle: nil,
                imageURL: video.images?.first?.image ?? apiData?.snippet.thumbnails.highestQuality?.url,
                videoInfo: EventItemViewModel.VideoInfo(
                    author: video.author ?? apiData?.snippet.channelTitle ?? "",
                    videoURL: URL(string: "https://www.youtube.com/watch?v=\(video.link)"),
                    videoID: video.link,
                    isLive: apiData?.snippet.liveBroadcastContent != .noneLive
                )
            )
        }
    }

    private func makeViewModel(
        index: Int,
        event: Event,
        isFavorite: Bool,
        restaurants: [Restaurant]
    ) -> [EventItemViewModel] {
        let images = event.images ?? []
        let dateString = event.schedule.map { self.dateFormatter.string(from: $0) }.joined(separator: " - ")

        let eventRestaurantsIDs = event.restaurantsIDs ?? []
        let eventRestaurants = restaurants.filter { eventRestaurantsIDs.contains($0.id) }
        if eventRestaurants.isEmpty {
            return [
                EventItemViewModel(
                    id: index,
                    title: event.title,
                    isFavorite: isFavorite,
                    date: dateString,
                    restaurantTitle: nil,
                    imageURL: images.first?.image,
                    videoInfo: nil
                )
            ]
        }
        /*
         'imageIndex' is used to get image for each 'restaurant',
         whereas 'index' is 'event' index
        */
        return eventRestaurants.enumerated().map { (imageIndex, restaurant) in
            EventItemViewModel(
                id: index,
                title: event.title,
                isFavorite: isFavorite,
                date: dateString,
                restaurantTitle: restaurant.title,
                imageURL: images[safe: imageIndex]?.image ?? images.first?.image,
                videoInfo: nil
            )
        }
    }

    private func makeViewModel(index: Int, tag: Tag, eventsWithTags: [Event], isSelected: Bool) -> EventTagViewModel {
        return EventTagViewModel(
            id: index,
            title: tag.title,
            imageURL: tag.images?.first?.image,
            eventsCount: tag.count,
            isSelected: isSelected
        )
    }

    private func makeModel(from event: Event, isFavorite: Bool) -> Event {
        return Event(
            id: event.id,
            title: event.title,
            description: event.description,
            bookingText: event.bookingText,
            isFavorite: isFavorite,
            schedule: event.schedule,
            restaurantsIDs: event.restaurantsIDs,
            images: event.images,
            partnerLink: event.partnerLink,
            tagsIDs: event.tagsIDs,
            bookingLink: event.bookingLink,
            buttonName: event.buttonName
        )
    }
}
