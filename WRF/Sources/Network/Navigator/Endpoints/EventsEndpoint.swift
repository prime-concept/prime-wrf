import Alamofire
import Foundation
import PromiseKit

protocol EventsEndpointProtocol: AnyObject {
    func retrieve(
        page: Int,
        title: String?,
        tag: Tag.IDType?,
        date: Date?,
        cityID: String?
    ) -> EndpointResponse<NavigatorListResponse<Event>>
}

final class EventsEndpoint: NavigatorEndpoint, EventsEndpointProtocol {
    static let endpoint = "/screens/events"

    func retrieve(
        page: Int,
        title: String?,
        tag: Tag.IDType?,
        date: Date?,
        cityID: String? = nil
    ) -> EndpointResponse<NavigatorListResponse<Event>> {
        var params = Parameters()
        params["page"] = page
        if let title = title {
            params["query[dictionary_data.title][$regex]"] = title
        }
        if let cityID {
            params["query[dictionary_data.city]"] = cityID
        }
        if let tagID = tag {
            params["query[dictionary_data.tags]"] = tagID
        }
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let queryString = formatter.string(from: date)
            params["query[dictionary_data.schedule.start][$gte]"] = queryString + "T00:00:00.000Z"
            params["query[dictionary_data.schedule.end][$lte]"] = queryString + "T23:59:59.000Z"
        }
        return self.retrieve(endpoint: EventsEndpoint.endpoint, parameters: params)
    }
}
