//
//  User.swift
//  PeshkarikiTest
//
//  Created by Игорь on 28.04.2022.
//

import Foundation
import RealmSwift

final class User: Object, Codable {
    @Persisted var username: String = ""
    @Persisted var name: String = ""
}
