import CoreLocation
import PromiseKit
import UIKit

protocol SearchEventPresenterProtocol {
    func update(event model: SearchEventViewModel)

    func select(event id: SearchEventViewModel.IDType)
    func select(tag id: SearchEventTagViewModel.IDType)

    func loadNextEvents()
    func loadEvents()
}

final class SearchEventPresenter: SearchEventPresenterProtocol, SearchEventChildModuleInput {
    weak var viewController: SearchEventViewControllerProtocol?

    private let eventsEndpoint: EventsEndpointProtocol
    private let eventEndpoint: EventEndpointProtocol
    private let tagsEndpoint: TagsEndpointProtocol
    private let favoritesService: FavoritesServiceProtocol

    private let dateFormatter: DateFormatter

    private var pageable: Meta?
    private var events: [Event] = []
    private var response: NavigatorListResponse<Event>?

    private var searchQuery: String?
    private var isLoading = false {
        didSet {
            if self.isLoading, !self.events.isEmpty, self.selectedTag != nil {
                self.viewController?.showLoading()
            } else {
                self.viewController?.hideLoading()
            }
        }
    }

    private var selectedDate: Date?
    private var selectedTag: Tag?

    private var tags: [Tag] = []

    init(
        eventsEndpoint: EventsEndpointProtocol,
        eventEndpoint: EventEndpointProtocol,
        tagsEndpoint: TagsEndpointProtocol,
        favoritesService: FavoritesServiceProtocol
    ) {
        self.eventsEndpoint = eventsEndpoint
        self.eventEndpoint = eventEndpoint
        self.tagsEndpoint = tagsEndpoint
        self.favoritesService = favoritesService

        let formatter = FormatterHelper.makeCorrectLocaleDateFormatter()
        formatter.dateFormat = "d MMM yyy"
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
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API

    func load(query: String?) {
        self.searchQuery = query
        self.loadEvents(query: query, tag: self.selectedTag, date: nil)
    }

    func load(events date: Date) {
        self.selectedDate = date
        self.loadEvents(query: nil, tag: self.selectedTag, date: date)
    }

    func loadEvents() {
        self.loadEvents(query: nil, tag: nil, date: nil)
    }

    func loadNextEvents() {
        guard let pageable = self.pageable, pageable.hasNext, !self.isLoading else {
            return
        }
        self.isLoading = true
        DispatchQueue.global(qos: .userInitiated).promise {
            self.eventsEndpoint.retrieve(
                page: pageable.next,
                title: self.searchQuery,
                tag: nil,
                date: self.selectedDate, 
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

    func update(event model: SearchEventViewModel) {
        guard let event = self.events[safe: model.id] else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).promise {
            self.favoritesService.updateFavoritesStatus(
                resourceID: event.id,
                type: .events,
                isFavorite: model.isFavorite
            )
        }.catch { error in
            print("favorites presenter: error when executing favorite status change = \(error)")
        }
    }

    func select(event id: SearchEventViewModel.IDType) {
        guard let event = self.events[safe: id] else {
            return
        }
        self.viewController?.present(event: event)
    }

    func select(tag id: SearchEventTagViewModel.IDType) {
        guard let tag = tags[safe: id] else { return }
        if PGCMain.shared.featureFlags.searching.showTagsForRestaurants {
            selectedTag = selectedTag == tag ? nil : tag
        } else {
            selectedTag = tag
        }
        loadEvents(query: nil, tag: selectedTag, date: nil)
    }

    // MARK: - Private API

    private func loadEvents(query: String?, tag: Tag?, date: Date?) {
        self.isLoading = true

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.eventsEndpoint.retrieve(
                page: 1,
                title: query,
                tag: tag?.id,
                date: date,
                cityID: nil
            ).result
        }.then(on: queue) { response -> Promise<(NavigatorListResponse<Event>, [Tag])> in
            if !self.tags.isEmpty {
                return .value((response, self.tags))
            }

            return self.tagsEndpoint.retrieve().result.map { (response, $0.events) }
        }.done { response, tags in
            self.response = response
            self.pageable = response.pageable
            self.events = response.items
            self.tags = tags

            let events = self.events.enumerated().compactMap {
                self.makeViewModel(
                    index: $0,
                    event: $1,
                    isFavorite: $1.isFavorite,
                    restaurants: response.dependencies.restaurants
                )
            }

            let tags = self.tags
                .enumerated()
                .compactMap { (index, loadedTag) -> SearchEventTagViewModel? in
                    if 
                        PGCMain.shared.featureFlags.searching.showTagsForRestaurants,
                        loadedTag.title == "Все"
                    {
                        return nil
                    }
                    return self.makeViewModel(
                        index: index,
                        tag: loadedTag,
                        eventsWithTags: response.items.filter { $0.tagsIDs?.contains(loadedTag.id) == true },
                        isSelected: tag?.id == loadedTag.id
                    )
                }

            let debounce: TimeInterval = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + debounce) {
                self.viewController?.set(events: events)
                self.viewController?.set(eventsCount: response.pageable.total)
                self.viewController?.set(
                    state: self.makeState(
                        itemCount: events.count,
                        searchParamsAreEmpty: (query ?? "").isEmpty && tag == nil && date == nil
                    )
                )

                self.viewController?.set(tags: tags)
            }
        }.ensure {
            self.isLoading = false
        }.catch { error in
            print("search restaurants presenter: error while loading restaurants = \(error.localizedDescription)")
        }
    }

    private func loadEvent(id: Event.IDType) {
        DispatchQueue.global(qos: .userInitiated).promise {
            self.eventEndpoint.retrieve(id: id).result
        }.done { response in
            self.events.insert(response.item, at: 0)

            let total = (self.response?.pageable.total ?? 0) + 1
            self.viewController?.set(eventsCount: total)

            self.viewController?.set(
                events: self.events.enumerated().compactMap {
                    self.makeViewModel(
                        index: $0,
                        event: $1,
                        isFavorite: $1.isFavorite,
                        restaurants: response.dependencies.restaurants
                    )
                }
            )
        }.catch { error in
            print("favorites presenter: error when loading event = \(error)")
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
            self.viewController?.set(index: index, event: viewModel)
        } else {
            self.loadEvent(id: resourceId)
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
            self.viewController?.set(index: index, event: viewModel)
        }
    }

    private func makeState(itemCount: Int, searchParamsAreEmpty: Bool) -> SearchEventView.State {
        if itemCount == 0 && !searchParamsAreEmpty {
            return .querySearchIsEmpty
        }
        if itemCount == 0 {
            return .data(hasData: false)
        }
        return .data(hasData: itemCount != 0)
    }

    private func makeViewModel(
        index: Int,
        event: Event,
        isFavorite: Bool,
        restaurants: [Restaurant]
    ) -> [SearchEventViewModel] {
        let images = event.images ?? []
        let eventRestaurantsIDs = event.restaurantsIDs ?? []
        let eventRestaurants = restaurants.filter { eventRestaurantsIDs.contains($0.id) }

        let dateString = event.schedule.map { self.dateFormatter.string(from: $0) }.joined(separator: " - ")

        if eventRestaurants.isEmpty {
            return [
                SearchEventViewModel(
                    id: index,
                    title: event.title,
                    description: event.description,
                    bookingText: event.bookingText,
                    isFavorite: isFavorite,
                    date: dateString,
                    restaurantTitle: nil,
                    imageURL: images.first?.image
                )
            ]
        }
        return eventRestaurants.enumerated().map { (index, restaurant) in
            SearchEventViewModel(
                id: index,
                title: event.title,
                description: event.description,
                bookingText: event.bookingText,
                isFavorite: isFavorite,
                date: dateString,
                restaurantTitle: restaurant.title,
                imageURL: images[safe: index]?.image ?? images.first?.image
            )
        }
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

    private func makeViewModel(
        index: Int,
        tag: Tag,
        eventsWithTags: [Event],
        isSelected: Bool
    ) -> SearchEventTagViewModel {
        return SearchEventTagViewModel(
            id: index,
            title: tag.title,
            imageURL: tag.images?.first?.image,
            eventsCount: tag.count,
            isSelected: isSelected
        )
    }
}
