//
//  TMDBEnvironment.swift
//  Cineverse
//

import Foundation

struct TMDBEnvironment {
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
        bundle: Bundle = .main,
        locale: Locale = .current
    ) -> TMDBEnvironment {
        make(
            infoDictionary: bundle.infoDictionary ?? [:],
            locale: locale
        )
    }

    static func make(
        infoDictionary: [String: Any],
        locale: Locale
    ) -> TMDBEnvironment {
        let configuredBaseURLString = nonEmptyValue(
            infoDictionary["TMDB_BASE_URL"] as? String
        )
        let baseURL = validatedBaseURL(configuredBaseURLString) ?? defaultBaseURL

        let token = nonEmptyValue(
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
            .compactMap { normalizedValue($0) }
            .first { !$0.isEmpty }
    }

    private static func normalizedValue(_ value: String?) -> String? {
        guard var trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        // Xcode may preserve quoted xcconfig values in Info.plist.
        if trimmed.hasPrefix("\""), trimmed.hasSuffix("\""), trimmed.count >= 2 {
            trimmed.removeFirst()
            trimmed.removeLast()
        }

        return trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
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
