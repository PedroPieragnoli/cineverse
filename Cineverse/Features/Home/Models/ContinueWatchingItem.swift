//
//  ContinueWatchingItem.swift
//  Cineverse
//

import Foundation

struct ContinueWatchingItem: Identifiable {
    let movie: Movie
    /// Watch progress as a value between 0.0 and 1.0
    let progress: Double
    let remainingSeconds: Int
    var id: Int { movie.id }

    var remainingTimeText: String {
        ContinueWatchingDurationFormatter.remainingTimeText(
            seconds: remainingSeconds,
            unitsStyle: .abbreviated
        )
    }

    init(movie: Movie, progress: Double, remainingSeconds: Int) {
        let sanitizedProgress = progress.isFinite ? progress : 0

        self.movie = movie
        self.progress = min(max(sanitizedProgress, 0), 1)
        self.remainingSeconds = max(remainingSeconds, 0)
    }
}

extension ContinueWatchingItem {
    var remainingTimeAccessibilityText: String {
        ContinueWatchingDurationFormatter.remainingTimeText(
            seconds: remainingSeconds,
            unitsStyle: .full
        )
    }
}
