//
//  PhotoAsyncIterator.swift
//  PeshkarikiTest
//
//  Created by Игорь on 12.05.2022.
//

import Foundation

struct PhotoAsyncIterator {

    // MARK: - Properties

    private var query: String
    private var totalPages: Int
    private var currentPage: Int = 1

    // MARK: - Lifecycle

    init(query: String, totalPages: Int) {
        self.query = query
        self.totalPages = totalPages
    }

    // MARK: - Methods

    mutating func next(completion: @escaping ([Photo]?) -> Void) {
        if currentPage > totalPages {
            completion(nil)
            return
        }

        NetworkService.searchPhotos(query: query, page: currentPage) { result in
            switch result {
            case .success(let photos):
                completion(photos)
            case .failure(_):
                completion(nil)
            }
        }

        currentPage += 1
    }
}
