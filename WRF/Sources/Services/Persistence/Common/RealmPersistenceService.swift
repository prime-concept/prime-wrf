import Foundation
import RealmSwift

protocol RealmPersistenceServiceProtocol: AnyObject {
    associatedtype PersistentType = RealmObjectConvertible

    func write(objects: [PersistentType])
    func write(object: PersistentType)
    func read(predicate: NSPredicate) -> [PersistentType]
    func read() -> [PersistentType]
    func delete(predicate: NSPredicate)
}

class RealmPersistenceService<T: RealmObjectConvertible>: RealmPersistenceServiceProtocol {
    private let currentSchemaVersion: UInt64 = 0

    private lazy var config = Realm.Configuration(
        schemaVersion: self.currentSchemaVersion,
        migrationBlock: { _, _ in
            // potentially lengthy data migration
        },
        deleteRealmIfMigrationNeeded: true
    )

    func write(objects: [T]) {
        do {
            let realm = try Realm(configuration: self.config)
            try realm.write {
                for object in objects {
                    realm.create(
                        T.RealmObjectType.self,
                        value: object.realmObject,
                        update: .all
                    )
                }
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func write(object: T) {
        write(objects: [object])
    }

    func read(predicate: NSPredicate) -> [T] {
        do {
            let realm = try Realm(configuration: self.config)
            let results = realm
                .objects(T.RealmObjectType.self)
                .filter(predicate)
                .map { T(realmObject: $0) }

            return Array(results)
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }

    func read() -> [T] {
        do {
            let realm = try Realm(configuration: self.config)
            let results = realm
                .objects(T.RealmObjectType.self)
                .map { T(realmObject: $0) }

            return Array(results)
        } catch {
            assertionFailure(error.localizedDescription)
            return []
        }
    }

    func delete(predicate: NSPredicate) {
        do {
            let realm = try Realm(configuration: self.config)
            let objects = realm
                .objects(T.RealmObjectType.self)
                .filter(predicate)

            guard let strongObject = objects.first else {
                return
            }

            try realm.write {
                realm.delete(strongObject)
            }
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

	func deleteAll() {
		do {
			let realm = try Realm(configuration: config)
			try realm.write {
				realm.deleteAll()
			}
		} catch {
			assertionFailure(error.localizedDescription)
		}
	}
}
