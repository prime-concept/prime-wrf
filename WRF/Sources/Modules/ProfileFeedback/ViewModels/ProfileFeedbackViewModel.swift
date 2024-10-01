import UIKit

struct ProfileFeedbackViewModel {
    let type: ProfileFeedbackType
    let email: String
    let phone: String
    let review: String
    let images: [UIImage]

    enum ProfileFeedbackType: String {
        case problem
        case idea
    }
}
