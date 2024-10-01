import Foundation
import PromiseKit

protocol FeedbackPresenterProtocol: AnyObject {
    func createFeedback(viewModel: FeedbackViewModel)
}

final class FeedbackPresenter: FeedbackPresenterProtocol {
    weak var viewController: FeedbackViewControllerProtocol?

    private let restaurantID: PrimePassRestaurantIDType
    private let primePassFeedbackEndpoint: PrimePassFeedbackEndpointProtocol
    private let authService: AuthServiceProtocol

    init(
        restaurantID: PrimePassRestaurantIDType,
        primePassFeedbackEndpoint: PrimePassFeedbackEndpointProtocol,
        authService: AuthServiceProtocol
    ) {
        self.restaurantID = restaurantID
        self.primePassFeedbackEndpoint = primePassFeedbackEndpoint
        self.authService = authService
    }

    func createFeedback(viewModel: FeedbackViewModel) {
        guard let authData = self.authService.authorizationData else {
            return
        }
        let request = PrimePassFeedbackRequest(
            userID: authData.userID,
            restaurantID: self.restaurantID,
            review: viewModel.review,
            assessment: viewModel.assessment,
            publish: viewModel.publish,
            improve: viewModel.assessment > 3 ? [] : viewModel.improve
        )

        DispatchQueue.global(qos: .userInitiated).promise {
            self.primePassFeedbackEndpoint.createReview(request: request).result
        }.done { response in
            switch response.status {
            case .ok:
                DispatchQueue.main.async {
                    self.viewController?.dismissViewController()
                }
            case .error:
                print("feedback presenter: response with error \(response.error.debugDescription)")
            default:
                return
            }
        }.catch { error in
            print("feedback presenter: error when creating feedback = \(error)")
        }
    }
}
