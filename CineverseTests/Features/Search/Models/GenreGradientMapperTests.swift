//
//  GenreGradientMapperTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse

struct GenreGradientMapperTests {
    @Test("Same display index always resolves to the same palette slot")
    func sameDisplayIndexKeepsSamePaletteSlot() {
        let firstIndex = GenreGradientMapper.paletteIndex(for: 5)
        let secondIndex = GenreGradientMapper.paletteIndex(for: 5)

        #expect(firstIndex == secondIndex)
    }

    @Test("Palette slot selection follows input order")
    func paletteSlotSelectionFollowsInputOrder() {
        let action = makeGenre(id: 28, "Action")
        let drama = makeGenre(id: 18, "Drama")

        let firstMapping = GenreGradientMapper.map([action, drama])
        let secondMapping = GenreGradientMapper.map([drama, action])

        #expect(firstMapping[0].style.startColor == secondMapping[0].style.startColor)
        #expect(firstMapping[1].style.endColor == secondMapping[1].style.endColor)
        #expect(firstMapping[0].genre.id == action.id)
        #expect(secondMapping[0].genre.id == drama.id)
    }

    @Test("Display indexes larger than the palette count wrap using modulo")
    func largerDisplayIndexesWrapWithModulo() {
        let paletteCount = GenreGradientMapper.palette.count
        let displayIndex = paletteCount * 3 + 5

        #expect(GenreGradientMapper.paletteIndex(for: displayIndex) == 5)
    }

    @Test("More genres than palette entries reuse palette styles without changing order")
    func moreGenresThanPaletteEntriesReuseStylesAndPreserveOrder() {
        let genres = (0..<(GenreGradientMapper.palette.count + 2)).map { index in
            makeGenre(id: index, "Genre \(index)")
        }

        let items = GenreGradientMapper.map(genres)

        #expect(items.map(\.genre.id) == genres.map(\.id))
        #expect(items.count == genres.count)
        #expect(items[0].style.startColor == items[GenreGradientMapper.palette.count].style.startColor)
        #expect(items[1].style.endColor == items[GenreGradientMapper.palette.count + 1].style.endColor)
    }

    @Test("Empty input produces no display items")
    func emptyInputProducesNoDisplayItems() {
        #expect(GenreGradientMapper.map([]).isEmpty)
    }

    // MARK: - Helpers

    private func makeGenre(id: Int, _ name: String) -> Genre {
        Genre(id: id, name: name)
    }
}
