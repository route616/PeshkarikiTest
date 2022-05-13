//
//  Location.swift
//  PeshkarikiTest
//
//  Created by Игорь on 28.04.2022.
//

import Foundation
import RealmSwift

final class Location: Object, Codable {
    @Persisted var title: String? = ""
}
