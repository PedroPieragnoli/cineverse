//
//  DurationTextFormatterTests.swift
//  CineverseTests
//

import Testing
@testable import Cineverse
import Foundation

struct DurationTextFormatterTests {
    private func expectedFormattedValue(
        from seconds: Int,
        unitsStyle: DateComponentsFormatter.UnitsStyle,
        allowedUnits: NSCalendar.Unit,
        zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior
    ) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior

        var calendar = Calendar.autoupdatingCurrent
        let localization = Bundle.main.preferredLocalizations.first ?? Locale.autoupdatingCurrent.identifier
        calendar.locale = Locale(identifier: localization)
        formatter.calendar = calendar

        return formatter.string(from: TimeInterval(seconds))
    }

    @Test("Returns formatted value for valid positive duration")
    func returnsFormattedValueForPositiveDuration() {
        let value = DurationTextFormatter.string(
            from: 3_661,
            unitsStyle: .abbreviated,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropLeading]
        )

        let expectedValue = expectedFormattedValue(
            from: 3_661,
            unitsStyle: .abbreviated,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropLeading]
        )

        #expect(value == expectedValue)
    }

    @Test("Negative seconds are clamped to zero")
    func negativeSecondsAreClampedToZero() {
        let negativeValue = DurationTextFormatter.string(
            from: -120,
            unitsStyle: .positional,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.pad]
        )

        let zeroValue = DurationTextFormatter.string(
            from: 0,
            unitsStyle: .positional,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.pad]
        )

        #expect(negativeValue == zeroValue)
    }

    @Test("Allowed units change the formatted output")
    func allowedUnitsChangeOutput() {
        let hoursAndMinutes = DurationTextFormatter.string(
            from: 3_661,
            unitsStyle: .abbreviated,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropLeading]
        )

        let minutesOnly = DurationTextFormatter.string(
            from: 3_661,
            unitsStyle: .abbreviated,
            allowedUnits: [.minute],
            zeroFormattingBehavior: [.dropLeading]
        )

        #expect(hoursAndMinutes != nil)
        #expect(minutesOnly != nil)
        #expect(hoursAndMinutes != minutesOnly)
    }

    @Test("Zero duration still returns formatted text with hour/minute units")
    func zeroDurationReturnsFormattedText() {
        let value = DurationTextFormatter.string(
            from: 0,
            unitsStyle: .abbreviated,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropAll]
        )

        let expectedValue = expectedFormattedValue(
            from: 0,
            unitsStyle: .abbreviated,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropAll]
        )

        #expect(value == expectedValue)
    }

    @Test("Positional formatting handles minute/second boundaries")
    func positionalFormattingBoundaryTransitions() {
        let fiftyNineSeconds = DurationTextFormatter.string(
            from: 59,
            unitsStyle: .positional,
            allowedUnits: [.minute, .second],
            zeroFormattingBehavior: [.pad]
        )

        let sixtySeconds = DurationTextFormatter.string(
            from: 60,
            unitsStyle: .positional,
            allowedUnits: [.minute, .second],
            zeroFormattingBehavior: [.pad]
        )

        let threeThousandFiveHundredNinetyNineSeconds = DurationTextFormatter.string(
            from: 3_599,
            unitsStyle: .positional,
            allowedUnits: [.minute, .second],
            zeroFormattingBehavior: [.pad]
        )

        let threeThousandSixHundredSeconds = DurationTextFormatter.string(
            from: 3_600,
            unitsStyle: .positional,
            allowedUnits: [.minute, .second],
            zeroFormattingBehavior: [.pad]
        )

        #expect(fiftyNineSeconds == "00:59")
        #expect(sixtySeconds == "01:00")
        #expect(threeThousandFiveHundredNinetyNineSeconds == "59:59")
        #expect(threeThousandSixHundredSeconds == "60:00")
    }

    @Test("Default parameters match explicit defaults")
    func defaultParametersMatchExplicitDefaults() {
        let usingDefaults = DurationTextFormatter.string(
            from: 3_661,
            unitsStyle: .abbreviated
        )

        let usingExplicitDefaults = DurationTextFormatter.string(
            from: 3_661,
            unitsStyle: .abbreviated,
            allowedUnits: [.hour, .minute],
            zeroFormattingBehavior: [.dropLeading]
        )

        #expect(usingDefaults == usingExplicitDefaults)
    }
}
