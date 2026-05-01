//
//  DefaultSearchRepository.swift
//  Cineverse
//

import Foundation

struct DefaultSearchRepository: SearchRepository {
    private let remoteDataSource: SearchRemoteDataSource

    init(remoteDataSource: SearchRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        try await remoteDataSource.searchMovies(query: query, page: page)
    }

    func fetchGenres() async throws -> [Genre] {
        let response = try await remoteDataSource.fetchGenres()
        return response.genres
    }
}

extension DefaultSearchRepository {
    static func live(
        environment: TMDBEnvironment = .live(),
        session: URLSession = .shared
    ) -> DefaultSearchRepository {
        let httpClient = URLSessionHTTPClient(
            baseURL: environment.baseURL,
            session: session
        )
        let requestBuilder = TMDBRequestBuilder(environment: environment)
        let remoteDataSource = TMDBSearchRemoteDataSource(
            httpClient: httpClient,
            requestBuilder: requestBuilder
        )

        return DefaultSearchRepository(remoteDataSource: remoteDataSource)
    }
}
