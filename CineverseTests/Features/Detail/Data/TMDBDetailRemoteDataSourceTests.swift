//
//  TMDBDetailRemoteDataSourceTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct TMDBDetailRemoteDataSourceTests {
    @Test("Movie detail request uses expected path, auth and locale")
    func movieDetailRequestUsesPathAuthAndLocale() async throws {
        let (dataSource, client) = makeSUT(language: "pt", region: "BR")
        client.responseDataByPath["/movie/550"] = encode(
            MovieDetailResponse(
                id: 550,
                title: "Fight Club",
                overview: "The first rule of Fight Club is: you do not talk about Fight Club.",
                posterPath: "/poster.jpg",
                releaseDate: "1999-10-15",
                voteAverage: 8.4,
                runtime: 139,
                genres: [Genre(id: 18, name: "Drama")]
            )
        )

        let response = try await dataSource.fetchMovieDetail(movieID: 550)
        let request = try #require(client.capturedRequests.first)

        #expect(response.id == 550)
        #expect(request.method == .get)
        #expect(request.path == "/movie/550")
        #expect(request.headers["Authorization"] == "Bearer token-123")
        #expect(request.headers["Accept"] == "application/json")
        #expect(request.queryItems.contains { $0.name == "language" && $0.value == "pt" })
        #expect(request.queryItems.contains { $0.name == "region" && $0.value == "BR" })
        #expect(!request.queryItems.contains { $0.name == "api_key" })
    }

    @Test("Credits request uses expected path")
    func creditsRequestUsesExpectedPath() async throws {
        let (dataSource, client) = makeSUT()
        client.responseDataByPath["/movie/550/credits"] = encode(
            MovieCreditsResponse(
                cast: [
                    MovieCastResponse(
                        id: 1,
                        name: "Brad Pitt",
                        character: "Tyler Durden",
                        profilePath: "/brad.jpg",
                        order: 1
                    )
                ]
            )
        )

        let response = try await dataSource.fetchCredits(movieID: 550)
        let request = try #require(client.capturedRequests.first)

        #expect(response.cast.count == 1)
        #expect(request.method == .get)
        #expect(request.path == "/movie/550/credits")
    }

    @Test("Movie detail surfaces transport errors")
    func movieDetailSurfacesTransportError() async {
        let (dataSource, client) = makeSUT()
        client.errorByPath["/movie/550"] = TMDBNetworkingError.network

        await #expect(throws: TMDBNetworkingError.network) {
            _ = try await dataSource.fetchMovieDetail(movieID: 550)
        }
    }

    @Test("Movie detail throws missing token when access token is empty")
    func movieDetailThrowsMissingTokenWhenTokenIsEmpty() async {
        let (dataSource, _) = makeSUT(token: "")

        await #expect(throws: TMDBNetworkingError.missingTMDBToken) {
            _ = try await dataSource.fetchMovieDetail(movieID: 550)
        }
    }

    private func makeSUT(
        language: String = "en",
        region: String = "US",
        token: String = "token-123"
    ) -> (TMDBDetailRemoteDataSource, HTTPClientSpy) {
        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: token,
            language: language,
            region: region
        )
        let client = HTTPClientSpy()
        let dataSource = TMDBDetailRemoteDataSource(
            httpClient: client,
            requestBuilder: TMDBRequestBuilder(environment: environment)
        )
        return (dataSource, client)
    }
}
