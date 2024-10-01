import Alamofire
import CoreLocation
import Foundation
import PromiseKit

protocol RestaurantsEndpointProtocol: AnyObject {
    func retrieve(
        tag: Tag.IDType?,
        location: CLLocationCoordinate2D?,
        cityID: String?,
        tags: [TypedTag],
        page: Int,
        perPage: Int
    ) -> EndpointResponse<NavigatorListResponse<Restaurant>>

    func retrieve(page: Int, title: String?, tag: Tag.IDType?) -> EndpointResponse<NavigatorListResponse<Restaurant>>
    func retrieve(restaurantID: PrimePassRestaurantIDType) -> EndpointResponse<NavigatorListResponse<Restaurant>>
}

final class RestaurantsEndpoint: NavigatorEndpoint, RestaurantsEndpointProtocol {
    static let endpoint = "/screens/restaurants"

    func retrieve(
        tag: Tag.IDType?,
        location: CLLocationCoordinate2D?,
        cityID: String? = nil,
        tags: [TypedTag],
        page: Int = 1,
        perPage: Int = 10
    ) -> EndpointResponse<NavigatorListResponse<Restaurant>> {
        var headers: HTTPHeaders = [:]
        var parameters = Parameters()

        if let location {
            headers = self.makeLocationHeaders(coordinate: location)
        }

        if let cityID {
            parameters["query[dictionary_data.city]"] = cityID
        }

        if let tag {
            parameters["query[dictionary_data.tags]"] = tag
        }

        parameters["page"] = page
        parameters["pageSize"] = perPage

        TagType.allCases.forEach { type in
            parameters["query[dictionary_data.\(type.rawValue)][$in][]="] = tags
                .filter { $0.type == type }
                .map { $0.tag.id }
        }

        return self.retrieve(endpoint: RestaurantsEndpoint.endpoint, parameters: parameters, headers: headers)
    }

    func retrieve(page: Int, title: String?, tag: Tag.IDType?) -> EndpointResponse<NavigatorListResponse<Restaurant>> {
        var parameters = Parameters()
        parameters["page"] = page
        if let title {
            parameters["query[dictionary_data.title][$regex]"] = title
        }
        if let tag = tag {
            parameters["query[dictionary_data.tags]"] = tag
        }
        return self.retrieve(endpoint: RestaurantsEndpoint.endpoint, parameters: parameters)
    }

    func retrieve(restaurantID: PrimePassRestaurantIDType) -> EndpointResponse<NavigatorListResponse<Restaurant>> {
        let params = ["query[dictionary_data.primepass_id]": restaurantID]
        return self.retrieve(endpoint: RestaurantsEndpoint.endpoint, parameters: params)
    }
}
