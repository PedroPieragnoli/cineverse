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
        let environment = makeEnvironment(
            infoDictionary: [
                "TMDB_BASE_URL": "https://custom.tmdb.test/3",
                "TMDB_READ_ACCESS_TOKEN": "abc123"
            ]
        )

        #expect(environment.baseURL.absoluteString == "https://custom.tmdb.test/3")
        #expect(environment.readAccessToken == "abc123")
    }

    @Test("Environment falls back to en/US when there is no localization and no region")
    func missingLocalizationAndRegionFallBackToDefaults() {
        let environment = TMDBEnvironment.make(
            infoDictionary: [:],
            localization: nil,
            region: nil
        )

        #expect(environment.language == "en")
        #expect(environment.region == "US")
    }

    @Test("Environment sends the full app localization and the region to TMDB", arguments: ["pt-BR", "en"])
    func passesLocalizationAndRegionThrough(localization: String) {
        let environment = TMDBEnvironment.make(
            infoDictionary: [:],
            localization: localization,
            region: "BR"
        )

        #expect(environment.language == localization)
        #expect(environment.region == "BR")
    }

    @Test("Live environment takes the language from the app bundle and the region from the device locale")
    func liveUsesAppLocalizationAndDeviceRegion() throws {
        let bundleURL = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: bundleURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: bundleURL) }
        let appBundle = try #require(BrazilianPortugueseBundle(url: bundleURL))
        let environment = TMDBEnvironment.live(bundle: appBundle, locale: Locale(identifier: "en_US"))

        #expect(environment.language == "pt-BR")
        #expect(environment.region == "US")
    }

    @Test("Environment uses default base URL when configured value is invalid")
    func invalidBaseURLFallsBack() {
        let environment = makeEnvironment(infoDictionary: ["TMDB_BASE_URL": "invalid-url"])

        #expect(environment.baseURL.absoluteString == "https://api.themoviedb.org/3")
    }

    @Test("Environment rejects insecure HTTP base URL")
    func insecureHTTPBaseURLFallsBack() {
        let environment = makeEnvironment(infoDictionary: ["TMDB_BASE_URL": "http://custom.tmdb.test/3"])

        #expect(environment.baseURL.absoluteString == "https://api.themoviedb.org/3")
    }

    @Test("Environment rejects non-standard HTTP-like schemes")
    func nonStandardHTTPBaseURLFallsBack() {
        let environment = makeEnvironment(infoDictionary: ["TMDB_BASE_URL": "http+unix://socket/path"])

        #expect(environment.baseURL.absoluteString == "https://api.themoviedb.org/3")
    }

    @Test("Environment accepts HTTPS scheme regardless of case")
    func uppercaseHTTPSBaseURLIsAccepted() {
        let environment = makeEnvironment(infoDictionary: ["TMDB_BASE_URL": "HTTPS://custom.tmdb.test/3"])

        #expect(environment.baseURL.scheme?.lowercased() == "https")
        #expect(environment.baseURL.host == "custom.tmdb.test")
        #expect(environment.baseURL.path == "/3")
    }

    @Test("Environment reads token from info dictionary")
    func readsTokenFromInfoDictionary() {
        let environment = makeEnvironment(infoDictionary: ["TMDB_READ_ACCESS_TOKEN": "from-info"])

        #expect(environment.readAccessToken == "from-info")
    }

    @Test("Environment trims wrapping quotes from configured token values")
    func quotedTokenIsNormalized() {
        let environment = makeEnvironment(infoDictionary: ["TMDB_READ_ACCESS_TOKEN": "\"quoted-token\""])

        #expect(environment.readAccessToken == "quoted-token")
    }

    private func makeEnvironment(infoDictionary: [String: Any]) -> TMDBEnvironment {
        TMDBEnvironment.make(infoDictionary: infoDictionary, localization: "en", region: "US")
    }
}

/// The test host runs in English, so `Bundle.main` alone can't show that `live` reads its localization.
/// Built on a fresh directory because `Bundle` caches instances by path.
private final class BrazilianPortugueseBundle: Bundle, @unchecked Sendable {
    override var preferredLocalizations: [String] { ["pt-BR"] }
}
