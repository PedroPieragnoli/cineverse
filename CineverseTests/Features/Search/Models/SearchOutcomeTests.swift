//
//  SearchOutcomeTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct SearchOutcomeTests {
    private static let unexpandedFormatToken = "%lld"

    @Test("A failed search announces the error title")
    func failedSearchAnnouncesErrorTitle() {
        #expect(SearchOutcome.error.announcement == String(localized: "search.errorState.title"))
    }

    @Test("An empty search announces the empty state title")
    func emptySearchAnnouncesEmptyStateTitle() {
        #expect(SearchOutcome.empty.announcement == String(localized: "search.emptyState.title"))
    }

    @Test("The reused state titles resolve from the strings catalog instead of echoing the key")
    func stateTitlesResolveFromTheCatalog() {
        #expect(String(localized: "search.errorState.title") != "search.errorState.title")
        #expect(String(localized: "search.emptyState.title") != "search.emptyState.title")
    }

    @Test("The result count is substituted into the announcement")
    func announcementSubstitutesResultCount() {
        let oneResult = SearchOutcome.results(count: 1).announcement
        let sevenResults = SearchOutcome.results(count: 7).announcement

        #expect(oneResult.contains("1"))
        #expect(sevenResults.contains("7"))
    }

    @Test("Singular and plural counts select different stringsdict wordings")
    func announcementSelectsPluralWording() {
        let oneResult = SearchOutcome.results(count: 1).announcement
        let sevenResults = SearchOutcome.results(count: 7).announcement

        #expect(oneResult.filter { !$0.isNumber } != sevenResults.filter { !$0.isNumber })
    }

    @Test("The announcement never leaks an unexpanded format token")
    func announcementNeverLeaksFormatToken() {
        for count in [1, 7] {
            let text = SearchOutcome.results(count: count).announcement

            #expect(text.contains(Self.unexpandedFormatToken) == false)
        }
    }

    @Test("The pt-BR stringsdict bundles and expands its own plural forms")
    func portugueseStringsdictExpandsPluralForms() throws {
        let path = try #require(Bundle.main.path(forResource: "pt-BR", ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        let ptBR = Locale(identifier: "pt-BR")
        let format = String(
            localized: "search.results.count.accessibilityAnnouncement",
            bundle: bundle,
            locale: ptBR
        )

        #expect(String(format: format, locale: ptBR, 1) == "1 resultado encontrado")
        #expect(String(format: format, locale: ptBR, 7) == "7 resultados encontrados")
    }
}
