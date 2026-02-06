//
//  APIRequest.swift
//  Cineverse
//

import Foundation

struct APIRequest<Response: Decodable> {
    let method: HTTPMethod
    let path: String
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let cachePolicy: URLRequest.CachePolicy
    let decoder: JSONDecoder

    init(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        decoder: JSONDecoder = APIRequest.defaultDecoder
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.cachePolicy = cachePolicy
        self.decoder = decoder
    }

    static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
