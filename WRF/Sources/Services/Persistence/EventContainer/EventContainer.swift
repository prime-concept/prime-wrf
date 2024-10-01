import Foundation

/// A persistent object for storing additional 'Event' data without modifying the original object
struct EventContainer {
    let id: Event.IDType
    let description: String?
    let participants: [Restaurant]
    let assessments: [PrimePassAssessment]
}
