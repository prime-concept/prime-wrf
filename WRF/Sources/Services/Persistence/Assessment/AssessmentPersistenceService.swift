import Foundation
import PromiseKit
import RealmSwift

protocol AssessmentPersistenceServiceProtocol: AnyObject {
    func retrieve() -> Guarantee<[PrimePassAssessment]>
    func retrieve(by place: PrimePassRestaurantIDType) -> Guarantee<[PrimePassAssessment]>

    func save(assessments: [PrimePassAssessment]) -> Promise<Void>
}

final class AssessmentPersistenceService:
RealmPersistenceService<PrimePassAssessment>, AssessmentPersistenceServiceProtocol {
    static let shared = AssessmentPersistenceService()

    func retrieve() -> Guarantee<[PrimePassAssessment]> {
        return Guarantee<[PrimePassAssessment]> { seal in
            let assessments = self.read()
            seal(assessments)
        }
    }

    func retrieve(by place: PrimePassRestaurantIDType) -> Guarantee<[PrimePassAssessment]> {
        return Guarantee<[PrimePassAssessment]> { seal in
            let predicate = NSPredicate(format: "place == %@", place)
            let assessments = self.read(predicate: predicate)
            seal(assessments)
        }
    }

    func save(assessments: [PrimePassAssessment]) -> Promise<Void> {
        return Promise<Void> { seal in
            self.write(objects: assessments)
            seal.fulfill_()
        }
    }
}
