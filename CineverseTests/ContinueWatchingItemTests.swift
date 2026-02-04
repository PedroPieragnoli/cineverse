//
//  ContinueWatchingItemTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse
import Foundation

struct ContinueWatchingItemTests {
    @Test("Progress clamps to 0...1 and resets non-finite values")
    func progressNormalization() {
        let belowRange = ContinueWatchingItem(
            movie: makeMovie(),
            progress: -0.3,
            remainingSeconds: 3600
        )
        #expect(belowRange.progress == 0)

        let aboveRange = ContinueWatchingItem(
            movie: makeMovie(),
            progress: 1.8,
            remainingSeconds: 3600
        )
        #expect(aboveRange.progress == 1)

        let nanProgress = ContinueWatchingItem(
            movie: makeMovie(),
            progress: .nan,
            remainingSeconds: 3600
        )
        #expect(nanProgress.progress == 0)

        let infiniteProgress = ContinueWatchingItem(
            movie: makeMovie(),
            progress: .infinity,
            remainingSeconds: 3600
        )
        #expect(infiniteProgress.progress == 0)

        let negativeInfiniteProgress = ContinueWatchingItem(
            movie: makeMovie(),
            progress: -.infinity,
            remainingSeconds: 3600
        )
        #expect(negativeInfiniteProgress.progress == 0)
    }

    @Test("Remaining seconds clamp to non-negative values")
    func remainingSecondsNormalization() {
        let negativeRemainingSeconds = ContinueWatchingItem(
            movie: makeMovie(),
            progress: 0.5,
            remainingSeconds: -60
        )
        #expect(negativeRemainingSeconds.remainingSeconds == 0)
    }

    @Test("Identifier remains tied to movie id")
    func identifierFromMovie() {
        let item = ContinueWatchingItem(movie: makeMovie(id: 99), progress: 0.5, remainingSeconds: 20 * 60)
        #expect(item.id == 99)
    }

    @Test("Remaining time text interpolates localized format")
    func remainingTimeTextUsesLocalizedFormat() {
        let item = ContinueWatchingItem(movie: makeMovie(), progress: 0.5, remainingSeconds: 20 * 60)
        #expect(!item.remainingTimeText.contains("%@"))
        #expect(item.remainingTimeText != "continueWatching.remaining.left")
    }

    @Test("Duration formatter supports abbreviated and full unit styles")
    func durationFormattingStyles() {
        let abbreviated = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 80 * 60,
            unitsStyle: .abbreviated
        )
        let full = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 80 * 60,
            unitsStyle: .full
        )

        #expect(abbreviated.contains("h"))
        #expect(abbreviated.contains("m"))
        #expect(full.contains("hour"))
        #expect(full.contains("minute"))
    }

    @Test("Zero remaining time uses style-appropriate text")
    func zeroRemainingTimeStyles() {
        let item = ContinueWatchingItem(movie: makeMovie(), progress: 0.5, remainingSeconds: 0)
        #expect(!item.remainingTimeText.isEmpty)
        #expect(!item.remainingTimeAccessibilityText.isEmpty)
        #expect(item.remainingTimeText.contains("0m"))
        #expect(item.remainingTimeAccessibilityText.contains("0 minutes"))
    }

    @Test("Negative remaining time matches zero formatting")
    func negativeRemainingTimeMatchesZeroFormatting() {
        let negativeValue = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: -60,
            unitsStyle: .abbreviated
        )
        let zeroValue = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 0,
            unitsStyle: .abbreviated
        )

        #expect(negativeValue == zeroValue)
    }

    @Test("Zero remaining time uses short fallback for brief/short/positional styles")
    func zeroRemainingTimeUsesShortFallbackForShortLikeStyles() {
        let expectedShortFallback = String(localized: "continueWatching.remaining.zero.short")

        let briefValue = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 0,
            unitsStyle: .brief
        )
        let shortValue = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 0,
            unitsStyle: .short
        )
        let positionalValue = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 0,
            unitsStyle: .positional
        )

        #expect(briefValue == expectedShortFallback)
        #expect(shortValue == expectedShortFallback)
        #expect(positionalValue == expectedShortFallback)
    }

    @Test("Unknown units style falls back to full zero text for zero duration")
    func unknownUnitsStyleFallsBackToFullZeroTextAtZeroDuration() {
        let unknownStyle = DateComponentsFormatter.UnitsStyle(rawValue: Int.max)!
        let expectedFullFallback = String(localized: "continueWatching.remaining.zero.full")

        let zeroValue = ContinueWatchingDurationFormatter.formattedRemainingDuration(
            seconds: 0,
            unitsStyle: unknownStyle
        )

        #expect(zeroValue == expectedFullFallback)
    }

    // MARK: - Helpers

    private func makeMovie(id: Int = 1, title: String = "Sample Movie") -> Movie {
        Movie(
            id: id,
            adult: false,
            backdropPath: nil,
            genreIds: [],
            originalLanguage: "en",
            originalTitle: title,
            overview: "Overview",
            popularity: 0,
            posterPath: nil,
            releaseDate: "2025-01-01",
            title: title,
            video: false,
            voteAverage: 7,
            voteCount: 100
        )
    }
}
