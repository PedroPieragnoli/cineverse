//
//  DetailPosterHeroTransitionPolicy.swift
//  Cineverse
//

import CoreGraphics

enum DetailPosterHeroTransitionPolicy {
    static func isEnabled(
        source: DetailRoute.Source,
        sourcePosterFrame: CGRect?,
        reduceMotion: Bool
    ) -> Bool {
        guard source == .posterCard,
              !reduceMotion,
              let sourcePosterFrame,
              sourcePosterFrame.width > 0,
              sourcePosterFrame.height > 0 else {
            return false
        }

        return true
    }
}
