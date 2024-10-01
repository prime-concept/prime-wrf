import Foundation

/// A persistent object for storing additional 'Restaurant' data without modifying the original object
struct RestaurantDetailContainer {
    let id: Restaurant.IDType
    let description: String?
    let phone: String?
    let menu: String?
    let site: String?
    let assessment: PrimePassAssessment?
    let events: [Event]
    let tags: [Tag]
    let reviews: [PrimePassReview]
    let previewImages360: [GradientImage]
}
