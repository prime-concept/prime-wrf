import Alamofire
import Foundation
import PromiseKit

typealias PrimePassRestaurantIDType = String

protocol PrimePassFeedbackEndpointProtocol: AnyObject {
    func retrieveAssessment(
        place: PrimePassRestaurantIDType
    ) -> EndpointResponse<PrimePassArrayResponse<PrimePassAssessment>>
    func retrieveReviews(
        place: PrimePassRestaurantIDType
    ) -> EndpointResponse<PrimePassArrayResponse<PrimePassReview>>
    func createReview(
        request: PrimePassFeedbackRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassFeedbackResponse>>
    func createAppFeedback(
        request: PrimePassAppFeedbackRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassFeedbackResponse>>
}

final class PrimePassFeedbackEndpoint: PrimePassEndpoint, PrimePassFeedbackEndpointProtocol {
    static let endpoint = "/v1/crm/feedback"

    func retrieveAssessment(
        place: PrimePassRestaurantIDType
    ) -> EndpointResponse<PrimePassArrayResponse<PrimePassAssessment>> {
        let parameters = ["place": place]
        return self.retrieve(
            endpoint: "\(PrimePassFeedbackEndpoint.endpoint)/reviews/assessment",
            parameters: parameters
        )
    }

    func retrieveReviews(
        place: PrimePassRestaurantIDType
    ) -> EndpointResponse<PrimePassArrayResponse<PrimePassReview>> {
        let parameters = ["place": place]
        return self.retrieve(
            endpoint: "\(PrimePassFeedbackEndpoint.endpoint)/review",
            parameters: parameters
        )
    }

    func createReview(
        request: PrimePassFeedbackRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassFeedbackResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(
            endpoint: "\(PrimePassFeedbackEndpoint.endpoint)/review",
            parameters: parameters
        )
    }

    func createAppFeedback(
        request: PrimePassAppFeedbackRequest
    ) -> EndpointResponse<PrimePassResponse<PrimePassFeedbackResponse>> {
        let parameters = DictionaryHelper.makeDictionary(from: request)
        return self.create(
            endpoint: "\(PrimePassFeedbackEndpoint.endpoint)/new",
            parameters: parameters
        )
    }
}
