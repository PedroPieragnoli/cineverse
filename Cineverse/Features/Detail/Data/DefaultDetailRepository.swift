//
//  DefaultDetailRepository.swift
//  Cineverse
//

import Foundation

struct DefaultDetailRepository: DetailRepository {
    private enum Constants {
        static let maxCastItems = 10
    }

    private let remoteDataSource: DetailRemoteDataSource

    init(remoteDataSource: DetailRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchDetail(movieID: Int) async throws -> MovieDetailPayload {
        async let detailResult = captureResult { try await remoteDataSource.fetchMovieDetail(movieID: movieID) }
        async let creditsResult = captureResult { try await remoteDataSource.fetchCredits(movieID: movieID) }

        let (detail, credits) = await (detailResult, creditsResult)

        let detailResponse = try detail.get()
        let cast = mapCast(from: try? credits.get())

        return MovieDetailPayload(
            detail: detailResponse,
            cast: cast
        )
    }

    private func mapCast(from credits: MovieCreditsResponse?) -> [MovieCastMember] {
        let castList = credits?.cast ?? []

        return castList
            .sorted { lhs, rhs in
                switch (lhs.order, rhs.order) {
                case let (left?, right?):
                    return left < right
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return lhs.name < rhs.name
                }
            }
            .prefix(Constants.maxCastItems)
            .map {
                MovieCastMember(
                    id: $0.id,
                    name: $0.name,
                    character: $0.character,
                    profilePath: $0.profilePath
                )
            }
    }

    private func captureResult<T>(_ operation: () async throws -> T) async -> Result<T, Error> {
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }
}

extension DefaultDetailRepository {
    static func live(
        environment: TMDBEnvironment = .live(),
        session: URLSession = .shared
    ) -> DefaultDetailRepository {
        let httpClient = URLSessionHTTPClient(
            baseURL: environment.baseURL,
            session: session
        )
        let requestBuilder = TMDBRequestBuilder(environment: environment)
        let remoteDataSource = TMDBDetailRemoteDataSource(
            httpClient: httpClient,
            requestBuilder: requestBuilder
        )

        return DefaultDetailRepository(remoteDataSource: remoteDataSource)
    }
}
