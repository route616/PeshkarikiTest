//
//  Photo.swift
//  PeshkarikiTest
//
//  Created by Игорь on 28.04.2022.
//

import Foundation
import RealmSwift

final class Photo: Object, Codable {
    @Persisted var id: String = ""
    @Persisted var createdAt: Date = Date()
    @Persisted var blurHash: String = ""
    @Persisted var downloads: Int? = 0
    @Persisted var location: Location?
    @Persisted var urls: URLs? = URLs()
    @Persisted var user: User? = User()
}
