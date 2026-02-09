//
//  TMDBHomeRemoteDataSource.swift
//  Cineverse
//

import Foundation

struct TMDBHomeRemoteDataSource: HomeRemoteDataSource {
    private let httpClient: HTTPClient
    private let requestBuilder: TMDBRequestBuilder

    init(
        httpClient: HTTPClient,
        requestBuilder: TMDBRequestBuilder = TMDBRequestBuilder()
    ) {
        self.httpClient = httpClient
        self.requestBuilder = requestBuilder
    }

    func fetchTrending() async throws -> MovieResponse {
        try await send(path: "/trending/movie/week")
    }

    func fetchUpcoming() async throws -> MovieResponse {
        try await send(path: "/movie/upcoming")
    }

    func fetchGenres() async throws -> GenreResponse {
        try await send(path: "/genre/movie/list")
    }

    private func send<Response: Decodable>(path: String) async throws -> Response {
        let request: APIRequest<Response> = try requestBuilder.makeRequest(
            method: .get,
            path: path
        )
        return try await httpClient.send(request)
    }
}
