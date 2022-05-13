//
//  SearchResults.swift
//  PeshkarikiTest
//
//  Created by Игорь on 11.05.2022.
//

import Foundation

struct SearchResults: Codable {
    let total: Int
    let totalPages: Int
    let results: [Photo]
}
