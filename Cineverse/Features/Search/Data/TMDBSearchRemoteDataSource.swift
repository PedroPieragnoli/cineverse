//
//  TMDBSearchRemoteDataSource.swift
//  Cineverse
//

import Foundation

struct TMDBSearchRemoteDataSource: SearchRemoteDataSource {
    private let httpClient: HTTPClient
    private let requestBuilder: TMDBRequestBuilder

    init(
        httpClient: HTTPClient,
        requestBuilder: TMDBRequestBuilder = TMDBRequestBuilder()
    ) {
        self.httpClient = httpClient
        self.requestBuilder = requestBuilder
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        let request: APIRequest<MovieResponse> = try requestBuilder.makeRequest(
            method: .get,
            path: "/search/movie",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "include_adult", value: "false")
            ]
        )
        return try await httpClient.send(request)
    }

    func fetchGenres() async throws -> GenreResponse {
        let request: APIRequest<GenreResponse> = try requestBuilder.makeRequest(
            method: .get,
            path: "/genre/movie/list"
        )
        return try await httpClient.send(request)
    }
}
