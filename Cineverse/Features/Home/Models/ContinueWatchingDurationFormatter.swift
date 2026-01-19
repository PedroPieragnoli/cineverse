//
//  ContinueWatchingDurationFormatter.swift
//  Cineverse
//

import Foundation

enum ContinueWatchingDurationFormatter {
    static func formattedRemainingDuration(
        seconds: Int,
        unitsStyle: DateComponentsFormatter.UnitsStyle
    ) -> String {
        if seconds <= 0 {
            return zeroDurationText(for: unitsStyle)
        }

        if let value = DurationTextFormatter.string(
            from: seconds,
            unitsStyle: unitsStyle,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropLeading]
        ) {
            return value
        }

        return zeroDurationText(for: unitsStyle)
    }

    static func remainingTimeText(
        seconds: Int,
        unitsStyle: DateComponentsFormatter.UnitsStyle
    ) -> String {
        let formattedDuration = formattedRemainingDuration(
            seconds: seconds,
            unitsStyle: unitsStyle
        )
        let format = String(localized: "continueWatching.remaining.left")
        return String(format: format, formattedDuration)
    }

    private static func zeroDurationText(for unitsStyle: DateComponentsFormatter.UnitsStyle) -> String {
        let key: LocalizedStringResource

        switch unitsStyle {
        case .abbreviated, .brief, .short, .positional:
            key = "continueWatching.remaining.zero.short"
        case .full, .spellOut:
            key = "continueWatching.remaining.zero.full"
        @unknown default:
            key = "continueWatching.remaining.zero.full"
        }

        return String(localized: key)
    }
}
