//
//  DesignSystem.swift
//  Cineverse
//

import Foundation
import SwiftUI

/// Shared design tokens used across the app for consistent styling.
enum DesignSystem {
    // MARK: - Colors

    enum Colors {
        /// Placeholder background brightness (very dark gray)
        static let placeholderBrightness: CGFloat = 0.1

        /// Standard card background color
        static var cardBackground: Color {
            Color(white: placeholderBrightness)
        }
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        /// Standard corner radius for cards (12pt)
        static let card: CGFloat = 12
    }

    // MARK: - Opacity

    enum Opacity {
        /// Subtle border overlay (0.1)
        static let subtleBorder: CGFloat = 0.1
        /// Disabled/placeholder state (0.3)
        static let disabled: CGFloat = 0.3
        /// Loading indicator (0.6)
        static let loading: CGFloat = 0.6
    }

    // MARK: - Animation

    enum Animation {
        /// Standard transition duration (0.3s)
        static let standard: TimeInterval = 0.3
    }

    // MARK: - Borders

    enum Borders {
        /// Standard border width (1pt)
        static let standard: CGFloat = 1
    }

    // MARK: - Strings

    enum Strings {
        static let doubleTapToViewDetails = NSLocalizedString("accessibility.movieCard.hint", comment: "")
        static let noImageAvailable = NSLocalizedString("accessibility.poster.noImage", comment: "")
        static let imageFailedToLoad = NSLocalizedString("accessibility.poster.loadFailed", comment: "")
    }
}
