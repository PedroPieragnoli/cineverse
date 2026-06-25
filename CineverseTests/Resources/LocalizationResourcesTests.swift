//
//  LocalizationResourcesTests.swift
//  CineverseTests
//

import Foundation
import Testing

struct LocalizationResourcesTests {
    private static let tableName = "Localizable"
    private static let referenceLocalization = "en"
    private static let portugueseLocalization = "pt-BR"
    private static let localizations = [referenceLocalization, portugueseLocalization]
    private static let tableExtensions = ["strings", "stringsdict"]

    @Test("Tested localizations match the localizations the app ships")
    func testedLocalizationsMatchBundle() {
        #expect(Set(Bundle.main.localizations).subtracting(["Base"]) == Set(Self.localizations))
    }

    @Test(
        "Each localization resolves its strings tables from its own lproj folder",
        arguments: localizations, tableExtensions
    )
    func tableResolvesFromOwnLocalizationFolder(localization: String, tableExtension: String) throws {
        let url = try Self.tableURL(localization: localization, tableExtension: tableExtension)

        #expect(url.deletingLastPathComponent().lastPathComponent == "\(localization).lproj")
    }

    @Test(
        "Every localization defines the same top-level keys",
        arguments: tableExtensions
    )
    func localizationsShareTheSameKeys(tableExtension: String) throws {
        let referenceKeys = try Self.keys(localization: Self.referenceLocalization, tableExtension: tableExtension)

        for localization in Self.localizations where localization != Self.referenceLocalization {
            let keys = try Self.keys(localization: localization, tableExtension: tableExtension)
            #expect(keys.symmetricDifference(referenceKeys).isEmpty, "\(localization) key mismatch")
        }
    }

    @Test("A Portuguese locale resolves app strings in Portuguese")
    func portugueseLocaleResolvesPortugueseString() {
        let title = LocalizedStringResource("tab.home.title", locale: Self.portugueseLocale)

        #expect(String(localized: title) == "Início")
    }

    @Test("A Portuguese locale resolves pluralized app strings in Portuguese")
    func portugueseLocaleResolvesPortuguesePlural() {
        let format = LocalizedStringResource(
            "search.results.count.accessibilityAnnouncement",
            locale: Self.portugueseLocale
        )

        #expect(String.localizedStringWithFormat(String(localized: format), 2) == "2 resultados encontrados")
    }

    // MARK: - Helpers

    private static var portugueseLocale: Locale {
        Locale(identifier: portugueseLocalization)
    }

    private static func tableURL(localization: String, tableExtension: String) throws -> URL {
        try #require(
            Bundle.main.url(
                forResource: tableName,
                withExtension: tableExtension,
                subdirectory: nil,
                localization: localization
            )
        )
    }

    private static func keys(localization: String, tableExtension: String) throws -> Set<String> {
        let url = try tableURL(localization: localization, tableExtension: tableExtension)
        let entries = try #require(try NSDictionary(contentsOf: url, error: ()) as? [String: Any])
        return Set(entries.keys)
    }
}
