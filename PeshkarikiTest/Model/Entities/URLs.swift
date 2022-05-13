//
//  URLs.swift
//  PeshkarikiTest
//
//  Created by Игорь on 28.04.2022.
//

import Foundation
import RealmSwift

final class URLs: Object, Codable {
    @Persisted var regular: String = ""
    @Persisted var small: String = ""
    @Persisted var thumb: String = ""
}
