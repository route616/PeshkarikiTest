//
//  DatabaseService.swift
//  PeshkarikiTest
//
//  Created by Игорь on 04.05.2022.
//

import Foundation
import RealmSwift

final class DatabaseService {
    static let sharedInstance = DatabaseService()
    private init() {
        realm = try! Realm()
    }

    // MARK: - Data types

    enum Error: Swift.Error {
        case writeFailure
    }

    // MARK: - Properties

    var realm: Realm

    // MARK: - Methods

    func save(photo: Photo) {
        do {
            try realm.write {
                realm.create(Photo.self, value: photo)
            }
        } catch {
            fatalError("Unable to save photo")
        }
    }

    func delete(photoBy id: String) {
        let photo = realm.objects(Photo.self).where { $0.id.like(id) }
        do {
            try realm.write {
                realm.delete(photo)
            }
        } catch {
            fatalError("Unable to delete photo")
        }
    }

    func fetch() -> [Photo] {
        var photos = [Photo]()
        realm.objects(Photo.self).forEach {
            photos.append(Photo(value: $0))
        }
        return photos
    }

    func contains(id: String) -> Bool {
        let photo = realm.objects(Photo.self).where { $0.id.like(id) }
        if let _ = photo.first {
            return true
        } else {
            return false
        }
    }
}
