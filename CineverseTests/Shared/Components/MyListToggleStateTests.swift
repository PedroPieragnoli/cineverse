//
//  MyListToggleStateTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse

struct MyListToggleStateTests {
    @Test("Saved state resolves to the filled bookmark")
    func savedStateUsesFilledBookmark() {
        #expect(MyListToggleState(isInMyList: true).symbolName == "bookmark.fill")
    }

    @Test("Unsaved state resolves to the outline bookmark")
    func unsavedStateUsesOutlineBookmark() {
        #expect(MyListToggleState(isInMyList: false).symbolName == "bookmark")
    }

    @Test("Both surfaces share one silhouette so the glyph fills rather than cuts")
    func glyphPairSharesOneSilhouette() {
        let saved = MyListToggleState.inList.symbolName
        let unsaved = MyListToggleState.notInList.symbolName

        #expect(saved == unsaved + ".fill")
    }

    @Test("State announcement differs between saved and unsaved")
    func announcementDiffersByState() {
        let saved = MyListToggleState.inList.accessibilityValue
        let unsaved = MyListToggleState.notInList.accessibilityValue

        #expect(!saved.isEmpty)
        #expect(!unsaved.isEmpty)
        #expect(saved != unsaved)
    }

    @Test("Initializing from a flag matches the named cases")
    func initFromFlagMatchesNamedCases() {
        #expect(MyListToggleState(isInMyList: true) == .inList)
        #expect(MyListToggleState(isInMyList: false) == .notInList)
    }
}
