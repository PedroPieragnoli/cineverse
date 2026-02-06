//
//  TMDBRequestBuilderTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct TMDBRequestBuilderTests {
    private struct SampleResponse: Decodable {
        let id: Int
    }

    @Test("Builder adds bearer auth and locale query values")
    func addsAuthAndLocaleQuery() throws {
        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "test-token",
            language: "pt",
            region: "BR"
        )

        let request: APIRequest<SampleResponse> = try TMDBRequestBuilder(environment: environment).makeRequest(
            path: "/trending/movie/week"
        )

        #expect(request.headers["Authorization"] == "Bearer test-token")
        #expect(request.headers["Accept"] == "application/json")
        #expect(request.queryItems.contains { $0.name == "language" && $0.value == "pt" })
        #expect(request.queryItems.contains { $0.name == "region" && $0.value == "BR" })
    }

    @Test("Builder strips api_key query item")
    func stripsAPIKeyQueryItem() throws {
        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token",
            language: "en",
            region: "US"
        )

        let request: APIRequest<SampleResponse> = try TMDBRequestBuilder(environment: environment).makeRequest(
            path: "/movie/upcoming",
            queryItems: [
                URLQueryItem(name: "page", value: "2"),
                URLQueryItem(name: "api_key", value: "secret")
            ]
        )

        #expect(request.queryItems.contains { $0.name == "page" && $0.value == "2" })
        #expect(!request.queryItems.contains { $0.name == "api_key" })
    }

    @Test("Builder overrides language and region query items with environment values")
    func overridesLocaleQueryItems() throws {
        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: "token",
            language: "pt",
            region: "BR"
        )

        let request: APIRequest<SampleResponse> = try TMDBRequestBuilder(environment: environment).makeRequest(
            path: "/discover/movie",
            queryItems: [
                URLQueryItem(name: "language", value: "en"),
                URLQueryItem(name: "region", value: "US"),
                URLQueryItem(name: "page", value: "1")
            ]
        )

        let languageItems = request.queryItems.filter { $0.name == "language" }
        let regionItems = request.queryItems.filter { $0.name == "region" }

        #expect(languageItems.count == 1)
        #expect(regionItems.count == 1)
        #expect(languageItems.first?.value == "pt")
        #expect(regionItems.first?.value == "BR")
        #expect(request.queryItems.contains { $0.name == "page" && $0.value == "1" })
    }

    @Test("Builder fails when token is missing")
    func failsWithoutToken() {
        let environment = TMDBEnvironment(
            baseURL: URL(string: "https://api.themoviedb.org/3")!,
            readAccessToken: nil,
            language: "en",
            region: "US"
        )

        #expect(throws: TMDBNetworkingError.missingTMDBToken) {
            let _: APIRequest<SampleResponse> = try TMDBRequestBuilder(environment: environment).makeRequest(
                path: "/genre/movie/list"
            )
        }
    }

}
