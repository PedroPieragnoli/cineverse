//
//  DurationTextFormatter.swift
//  Cineverse
//

import Foundation

enum DurationTextFormatter {
    static func string(
        from seconds: Int,
        unitsStyle: DateComponentsFormatter.UnitsStyle,
        allowedUnits: NSCalendar.Unit = [.hour, .minute],
        zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = [.dropLeading]
    ) -> String? {
        let clampedSeconds = max(seconds, 0)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitsStyle
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior

        var calendar = Calendar.autoupdatingCurrent
        let localization = Bundle.main.preferredLocalizations.first ?? Locale.autoupdatingCurrent.identifier
        calendar.locale = Locale(identifier: localization)
        formatter.calendar = calendar

        guard let value = formatter.string(from: TimeInterval(clampedSeconds)), !value.isEmpty else {
            return nil
        }

        return value
    }
}
