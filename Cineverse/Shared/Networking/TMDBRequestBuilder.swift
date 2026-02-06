//
//  TMDBRequestBuilder.swift
//  Cineverse
//

import Foundation

struct TMDBRequestBuilder {
    private let environment: TMDBEnvironment

    init(environment: TMDBEnvironment = .live()) {
        self.environment = environment
    }

    func makeRequest<Response: Decodable>(
        method: HTTPMethod = .get,
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        decoder: JSONDecoder = APIRequest<Response>.defaultDecoder
    ) throws -> APIRequest<Response> {
        guard let token = environment.readAccessToken, !token.isEmpty else {
            throw TMDBNetworkingError.missingTMDBToken
        }

        let normalizedQueryItems = queryItems.filter {
            $0.name != "api_key" && $0.name != "language" && $0.name != "region"
        }

        var mergedHeaders = headers
        mergedHeaders["Authorization"] = "Bearer \(token)"
        mergedHeaders["Accept"] = "application/json"

        let localizedQueryItems = normalizedQueryItems + [
            URLQueryItem(name: "language", value: environment.language),
            URLQueryItem(name: "region", value: environment.region)
        ]

        return APIRequest<Response>(
            method: method,
            path: path,
            queryItems: localizedQueryItems,
            headers: mergedHeaders,
            cachePolicy: cachePolicy,
            decoder: decoder
        )
    }
}
