//
//  TMDBEnvironmentTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct TMDBEnvironmentTests {
    @Test("Environment loads token and base URL from configuration values")
    func loadsConfiguredValues() {
        let environment = TMDBEnvironment.make(
            infoDictionary: [
                "TMDB_BASE_URL": "https://custom.tmdb.test/3",
                "TMDB_READ_ACCESS_TOKEN": "abc123"
            ],
            locale: Locale(identifier: "pt_BR")
        )

        #expect(environment.baseURL.absoluteString == "https://custom.tmdb.test/3")
        #expect(environment.readAccessToken == "abc123")
    }

    @Test("Environment falls back when locale has no region")
    func localeFallbackBehavior() {
        let environment = TMDBEnvironment.make(
            infoDictionary: [:],
            locale: Locale(identifier: "en")
        )

        #expect(environment.language == "en")
        #expect(environment.region == "US")
    }

    @Test("Environment uses default base URL when configured value is invalid")
    func invalidBaseURLFallsBack() {
        let environment = TMDBEnvironment.make(
            infoDictionary: ["TMDB_BASE_URL": "invalid-url"],
            locale: Locale(identifier: "en_US")
        )

        #expect(environment.baseURL.absoluteString == "https://api.themoviedb.org/3")
    }

    @Test("Environment rejects insecure HTTP base URL")
    func insecureHTTPBaseURLFallsBack() {
        let environment = TMDBEnvironment.make(
            infoDictionary: ["TMDB_BASE_URL": "http://custom.tmdb.test/3"],
            locale: Locale(identifier: "en_US")
        )

        #expect(environment.baseURL.absoluteString == "https://api.themoviedb.org/3")
    }

    @Test("Environment rejects non-standard HTTP-like schemes")
    func nonStandardHTTPBaseURLFallsBack() {
        let environment = TMDBEnvironment.make(
            infoDictionary: ["TMDB_BASE_URL": "http+unix://socket/path"],
            locale: Locale(identifier: "en_US")
        )

        #expect(environment.baseURL.absoluteString == "https://api.themoviedb.org/3")
    }

    @Test("Environment accepts HTTPS scheme regardless of case")
    func uppercaseHTTPSBaseURLIsAccepted() {
        let environment = TMDBEnvironment.make(
            infoDictionary: ["TMDB_BASE_URL": "HTTPS://custom.tmdb.test/3"],
            locale: Locale(identifier: "en_US")
        )

        #expect(environment.baseURL.scheme?.lowercased() == "https")
        #expect(environment.baseURL.host == "custom.tmdb.test")
        #expect(environment.baseURL.path == "/3")
    }

    @Test("Environment reads token from info dictionary")
    func readsTokenFromInfoDictionary() {
        let environment = TMDBEnvironment.make(
            infoDictionary: ["TMDB_READ_ACCESS_TOKEN": "from-info"],
            locale: Locale(identifier: "en_US")
        )

        #expect(environment.readAccessToken == "from-info")
    }

    @Test("Environment trims wrapping quotes from configured token values")
    func quotedTokenIsNormalized() {
        let environment = TMDBEnvironment.make(
            infoDictionary: ["TMDB_READ_ACCESS_TOKEN": "\"quoted-token\""],
            locale: Locale(identifier: "en_US")
        )

        #expect(environment.readAccessToken == "quoted-token")
    }
}
