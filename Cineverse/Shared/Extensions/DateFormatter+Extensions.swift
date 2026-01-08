//
//  DateFormatter+Extensions.swift
//  Cineverse
//

import Foundation

extension DateFormatter {
    /// Parses TMDB API date strings (yyyy-MM-dd)
    static let tmdbDateParser: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Formats dates for display
    static let movieDisplayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        return formatter
    }()
}
