//
//  TMDBEnvironment.swift
//  Cineverse
//

import Foundation

struct TMDBEnvironment: Sendable {
    private static let defaultBaseURLString = "https://api.themoviedb.org/3"
    private static let defaultBaseURL: URL = {
        guard let url = URL(string: defaultBaseURLString) else {
            preconditionFailure("Invalid TMDB base URL: \(defaultBaseURLString)")
        }
        return url
    }()
    private static let defaultLanguage = "en"
    private static let defaultRegion = "US"

    let baseURL: URL
    let readAccessToken: String?
    let language: String
    let region: String

    init(baseURL: URL, readAccessToken: String?, language: String, region: String) {
        self.baseURL = baseURL
        self.readAccessToken = readAccessToken?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.language = language
        self.region = region
    }

    static func live(
        processInfo: ProcessInfo = .processInfo,
        bundle: Bundle = .main,
        locale: Locale = .current
    ) -> TMDBEnvironment {
        make(
            environmentValues: processInfo.environment,
            infoDictionary: bundle.infoDictionary ?? [:],
            locale: locale
        )
    }

    static func make(
        environmentValues: [String: String],
        infoDictionary: [String: Any],
        locale: Locale
    ) -> TMDBEnvironment {
        let configuredBaseURLString = nonEmptyValue(
            environmentValues["TMDB_BASE_URL"],
            infoDictionary["TMDB_BASE_URL"] as? String
        )
        let baseURL = validatedBaseURL(configuredBaseURLString) ?? defaultBaseURL

        let token = nonEmptyValue(
            environmentValues["TMDB_READ_ACCESS_TOKEN"],
            infoDictionary["TMDB_READ_ACCESS_TOKEN"] as? String
        )

        let localeLanguage = locale.language.languageCode?.identifier ?? defaultLanguage
        let localeRegion = locale.region?.identifier ?? defaultRegion

        return TMDBEnvironment(
            baseURL: baseURL,
            readAccessToken: token,
            language: localeLanguage,
            region: localeRegion
        )
    }

    private static func nonEmptyValue(_ values: String?...) -> String? {
        values
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    private static func isValidBaseURL(_ url: URL?) -> Bool {
        guard
            let url,
            url.scheme?.caseInsensitiveCompare("https") == .orderedSame,
            let host = url.host, !host.isEmpty
        else {
            return false
        }

        return true
    }

    private static func validatedBaseURL(_ value: String?) -> URL? {
        guard let value, let url = URL(string: value), isValidBaseURL(url) else {
            return nil
        }

        return url
    }
}
