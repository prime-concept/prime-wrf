import UIKit

protocol SearchPresenterProtocol {
    func search(context: PageContext, query: String)
    func search(events date: Date)

    func pageScrolled(context: PageContext)
    func showCalendar()
    func didTapOnSearchCategory(name: String)
}

final class SearchPresenter: SearchPresenterProtocol {
    weak var viewController: SearchViewControllerProtocol?

    private var restaurantQuery: String?
    private var eventQuery: String?
    private var selectedDate: Date?

    // MARK: - Public API

    func search(context: PageContext, query: String) {
        switch context {
        case .restaurants:
            guard self.restaurantQuery != query else {
                return
            }
            self.restaurantQuery = query
            self.viewController?.search(restaurants: query)
        case .events:
            guard self.eventQuery != query else {
                return
            }
            self.eventQuery = query
            self.viewController?.search(events: query)
        case .delivery:
            break
        }
    }

    func search(events date: Date) {
        self.selectedDate = date
        self.viewController?.search(events: date)
    }

    func pageScrolled(context: PageContext) {
        switch context {
        case .restaurants:
            self.viewController?.set(search: self.restaurantQuery ?? "")
            self.viewController?.set(calendar: false)
        case .events:
            self.viewController?.set(search: self.eventQuery ?? "")
            self.viewController?.set(calendar: PGCMain.shared.featureFlags.searching.showCalendar)
        case .delivery:
            break
        }
    }

    func showCalendar() {
        self.viewController?.present(calendar: self.selectedDate ?? Date())
    }
    
    func didTapOnSearchCategory(name: String) {
        AnalyticsReportingService.shared.didTapOnSearchCategory(item: name)
    }
}
