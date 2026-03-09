//
//  DefaultDetailRepositoryTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct DefaultDetailRepositoryTests {
    @Test("Repository maps detail and credits into payload")
    func mapsSuccessfulResponses() async throws {
        let spy = DetailRemoteDataSourceSpy(
            detail: .success(makeDetailResponse(
                id: 550,
                title: "Fight Club",
                releaseDate: "1999-10-15",
                voteAverage: 8.4,
                runtime: 139,
                genres: [
                    Genre(id: 18, name: "Drama"),
                    Genre(id: 53, name: "Thriller"),
                    Genre(id: 80, name: "Crime")
                ]
            )),
            credits: .success(MovieCreditsResponse(cast: [
                makeCastResponse(id: 10, name: "Edward Norton", order: 1),
                makeCastResponse(id: 11, name: "Brad Pitt", order: 0)
            ]))
        )
        let repository = DefaultDetailRepository(remoteDataSource: spy)

        let payload = try await repository.fetchDetail(movieID: 550)

        #expect(spy.detailIDs == [550])
        #expect(spy.creditsIDs == [550])
        #expect(payload.title == "Fight Club")
        #expect(payload.ratingPercentage == 84)
        #expect(payload.releaseYear == "1999")
        #expect(payload.runtimeMinutes == 139)
        #expect(payload.topGenres.map(\.name) == ["Drama", "Thriller"])
        #expect(payload.cast.map(\.id) == [11, 10])
    }

    @Test("Credits failure still returns full detail payload")
    func creditsFailureStillReturnsPayload() async throws {
        let repository = DefaultDetailRepository(
            remoteDataSource: DetailRemoteDataSourceSpy(
                detail: .success(makeDetailResponse(
                    title: "Movie",
                    releaseDate: "2024-03-10",
                    voteAverage: 7.5,
                    runtime: 120,
                    genres: [Genre(id: 12, name: "Adventure")]
                )),
                credits: .failure(TMDBNetworkingError.network)
            )
        )

        let payload = try await repository.fetchDetail(movieID: 600)

        #expect(payload.title == "Movie")
        #expect(payload.runtimeMinutes == 120)
        #expect(payload.releaseYear == "2024")
        #expect(payload.topGenres.map(\.name) == ["Adventure"])
        #expect(payload.cast.isEmpty)
    }

    @Test("Detail failure surfaces the network error to the caller")
    func detailFailureSurfacesError() async {
        let repository = DefaultDetailRepository(
            remoteDataSource: DetailRemoteDataSourceSpy(
                detail: .failure(TMDBNetworkingError.decoding),
                credits: .success(MovieCreditsResponse(cast: []))
            )
        )

        await #expect(throws: TMDBNetworkingError.decoding) {
            _ = try await repository.fetchDetail(movieID: 999)
        }
    }

    @Test("Cast is capped at ten entries")
    func castCappedAtTen() async throws {
        let castResponses = (0..<12).map {
            makeCastResponse(id: $0, name: "Actor \($0)", order: $0)
        }
        let repository = DefaultDetailRepository(
            remoteDataSource: DetailRemoteDataSourceSpy(
                detail: .success(makeDetailResponse()),
                credits: .success(MovieCreditsResponse(cast: castResponses))
            )
        )

        let payload = try await repository.fetchDetail(movieID: 1)

        #expect(payload.cast.count == 10)
        #expect(payload.cast.map(\.id) == Array(0..<10))
    }

    @Test("Cast sort places ordered entries first and falls back to name")
    func castSortHandlesMissingOrder() async throws {
        let cast = [
            makeCastResponse(id: 1, name: "Zelda", order: 5),
            makeCastResponse(id: 2, name: "Alice", order: 2),
            makeCastResponse(id: 3, name: "Charlie", order: nil),
            makeCastResponse(id: 4, name: "Bob", order: nil)
        ]
        let repository = DefaultDetailRepository(
            remoteDataSource: DetailRemoteDataSourceSpy(
                detail: .success(makeDetailResponse()),
                credits: .success(MovieCreditsResponse(cast: cast))
            )
        )

        let payload = try await repository.fetchDetail(movieID: 1)

        #expect(payload.cast.map(\.id) == [2, 1, 4, 3])
    }

    @Test("Empty cast list yields an empty payload cast")
    func emptyCastYieldsEmptyPayloadCast() async throws {
        let repository = DefaultDetailRepository(
            remoteDataSource: DetailRemoteDataSourceSpy(
                detail: .success(makeDetailResponse()),
                credits: .success(MovieCreditsResponse(cast: []))
            )
        )

        let payload = try await repository.fetchDetail(movieID: 1)

        #expect(payload.cast.isEmpty)
    }

    @Test("Empty genres list yields empty topGenres")
    func emptyGenresYieldsEmptyTopGenres() async throws {
        let repository = DefaultDetailRepository(
            remoteDataSource: DetailRemoteDataSourceSpy(
                detail: .success(makeDetailResponse(genres: [])),
                credits: .success(MovieCreditsResponse(cast: []))
            )
        )

        let payload = try await repository.fetchDetail(movieID: 1)

        #expect(payload.topGenres.isEmpty)
    }
}

private func makeDetailResponse(
    id: Int = 1,
    title: String = "Title",
    overview: String = "Overview",
    posterPath: String? = "/poster.jpg",
    releaseDate: String? = "2024-01-01",
    voteAverage: Double = 7.5,
    runtime: Int? = 120,
    genres: [Genre] = []
) -> MovieDetailResponse {
    MovieDetailResponse(
        id: id,
        title: title,
        overview: overview,
        posterPath: posterPath,
        releaseDate: releaseDate,
        voteAverage: voteAverage,
        runtime: runtime,
        genres: genres
    )
}

private func makeCastResponse(
    id: Int,
    name: String = "Actor",
    character: String = "Role",
    profilePath: String? = "/profile.jpg",
    order: Int? = nil
) -> MovieCastResponse {
    MovieCastResponse(
        id: id,
        name: name,
        character: character,
        profilePath: profilePath,
        order: order
    )
}

private final class DetailRemoteDataSourceSpy: DetailRemoteDataSource, @unchecked Sendable {
    private(set) var detailIDs: [Int] = []
    private(set) var creditsIDs: [Int] = []
    private let detail: Result<MovieDetailResponse, Error>
    private let credits: Result<MovieCreditsResponse, Error>

    init(
        detail: Result<MovieDetailResponse, Error>,
        credits: Result<MovieCreditsResponse, Error>
    ) {
        self.detail = detail
        self.credits = credits
    }

    func fetchMovieDetail(movieID: Int) async throws -> MovieDetailResponse {
        detailIDs.append(movieID)
        return try detail.get()
    }

    func fetchCredits(movieID: Int) async throws -> MovieCreditsResponse {
        creditsIDs.append(movieID)
        return try credits.get()
    }
}
