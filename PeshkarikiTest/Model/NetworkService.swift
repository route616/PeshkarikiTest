//
//  NetworkService.swift
//  PeshkarikiTest
//
//  Created by Игорь on 28.04.2022.
//

import Foundation
import Alamofire

final class NetworkService {

    // MARK: - Data types

    enum Error: Swift.Error {
        case missingPhotosData
        case missingSearchData
        case missingImageData
        case missingDownloadsCount

        case decoderError
    }

    private enum Endpoint: String {
        case random = "/photos/random"
        case search = "/search/photos"
        case photo = "/photos/"
    }

    // MARK: - Methods

    static func fetchPhotosData(completion: @escaping (Result<[Photo], NetworkService.Error>) -> Void) {
        let query = ["client_id": Config.accessKey, "count": "30"]

        AF
            .request(Config.baseURL + Endpoint.random.rawValue, parameters: query)
            .responseData(queue: .global()) { data in
                guard let data = data.value else {
                    DispatchQueue.main.async {
                        completion(.failure(.missingPhotosData))
                    }
                    return
                }

                let decoder = JSONDecoder()

                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601

                do {
                    let decoded = try decoder.decode([Photo].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decoded))
                    }
                } catch DecodingError.dataCorrupted(let context) {
                    print("fetchPhotosData: " + context.debugDescription)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("\(key.stringValue) was not found, \(context.debugDescription)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("\(type) was expected, \(context.debugDescription)")
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("no value was found for \(type), \(context.debugDescription)")
                } catch {
                    print("I know not this error")
                }
            }
    }

    static func fetchDownloadsCount(
        by id: String,
        completion: @escaping (Result<Int, NetworkService.Error>) -> Void
    ) {
        let query = ["client_id": Config.accessKey]
        AF
            .request(Config.baseURL + Endpoint.photo.rawValue + id, parameters: query)
            .responseData(queue: .global()) { response in
                guard let data = response.value else {
                    DispatchQueue.main.async {
                        completion(.failure(.missingDownloadsCount))
                    }
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(Downloads.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decoded.downloads))
                    }
                } catch DecodingError.dataCorrupted(let context) {
                    print("fetchDownloadsCount: " + context.debugDescription)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("\(key.stringValue) was not found, \(context.debugDescription)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("\(type) was expected, \(context.debugDescription)")
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("no value was found for \(type), \(context.debugDescription)")
                } catch {
                    print("I know not this error")
                }
            }
    }

    static func generateIterator(
        query keyword: String,
        completion: @escaping (Result<PhotoAsyncIterator, NetworkService.Error>) -> Void
    ) {
        let query = ["client_id": Config.accessKey, "query": keyword, "per_page": "0"]

        AF
            .request(Config.baseURL + Endpoint.search.rawValue, parameters: query)
            .responseData(queue: .global()) { response in
                guard let data = response.value else {
                    DispatchQueue.main.async {
                        print("No data iterator")
                        completion(.failure(.missingSearchData))
                    }
                    return
                }

                let decoder = JSONDecoder()

                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601

                do {
                    let decoded = try decoder.decode(SearchResults.self, from: data)
                    let iterator = PhotoAsyncIterator(query: keyword, totalPages: decoded.totalPages)
                    DispatchQueue.main.async {
                        completion(.success(iterator))
                    }
                } catch DecodingError.dataCorrupted(let context) {
                    print("generateIterator: " + context.debugDescription)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("\(key.stringValue) was not found, \(context.debugDescription)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("\(type) was expected, \(context.debugDescription)")
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("no value was found for \(type), \(context.debugDescription)")
                } catch {
                    print("I know not this error")
                }
            }
    }

    static func searchPhotos(
        query keyword: String,
        page: Int,
        completion: @escaping (Result<[Photo], NetworkService.Error>) -> Void
    ) {
        let query = ["client_id": Config.accessKey, "query": keyword, "page": "\(page)", "per_page": "30"]

        AF
            .request(Config.baseURL + Endpoint.search.rawValue, parameters: query)
            .responseData(queue: .global()) { response in
                guard let data = response.value else {
                    DispatchQueue.main.async {
                        completion(.failure(.missingSearchData))
                    }
                    return
                }

                let decoder = JSONDecoder()

                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601

                do {
                    let decoded = try decoder.decode(SearchResults.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decoded.results))
                    }
                } catch DecodingError.dataCorrupted(let context) {
                    print("searchPhotos: " + context.debugDescription)
                } catch DecodingError.keyNotFound(let key, let context) {
                    print("\(key.stringValue) was not found, \(context.debugDescription)")
                } catch DecodingError.typeMismatch(let type, let context) {
                    print("\(type) was expected, \(context.debugDescription)")
                } catch DecodingError.valueNotFound(let type, let context) {
                    print("no value was found for \(type), \(context.debugDescription)")
                } catch {
                    print("I know not this error")
                }
            }
    }

    static func downloadPhoto(_ url: String, completion: @escaping (Result<Data, NetworkService.Error>) -> Void) {
        AF
            .request(url)
            .responseData(queue: .global()) { response in
                guard let data = response.value else {
                    DispatchQueue.main.async {
                        completion(.failure(.missingImageData))
                    }
                    return
                }

                DispatchQueue.main.async {
                    completion(.success(data))
                }
            }
    }
}
