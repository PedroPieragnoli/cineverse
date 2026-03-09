//
//  TMDBDetailRemoteDataSource.swift
//  Cineverse
//

import Foundation

struct TMDBDetailRemoteDataSource: DetailRemoteDataSource {
    private let httpClient: HTTPClient
    private let requestBuilder: TMDBRequestBuilder

    init(
        httpClient: HTTPClient,
        requestBuilder: TMDBRequestBuilder = TMDBRequestBuilder()
    ) {
        self.httpClient = httpClient
        self.requestBuilder = requestBuilder
    }

    func fetchMovieDetail(movieID: Int) async throws -> MovieDetailResponse {
        try await send(path: "/movie/\(movieID)")
    }

    func fetchCredits(movieID: Int) async throws -> MovieCreditsResponse {
        try await send(path: "/movie/\(movieID)/credits")
    }

    private func send<Response: Decodable>(path: String) async throws -> Response {
        let request: APIRequest<Response> = try requestBuilder.makeRequest(
            method: .get,
            path: path
        )
        return try await httpClient.send(request)
    }
}
