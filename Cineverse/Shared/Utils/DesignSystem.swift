//
//  DesignSystem.swift
//  Cineverse
//

import Foundation
import SwiftUI

enum DesignSystem {
    enum Colors {
        static let primary = Color(hex: "#9F2BFF")
        static let background = Color.black
        static let surface = Color(hex: "#121212")
        static let cardBackground = Color(hex: "#111827")
        static let buttonSecondaryBackground = Color.white.opacity(0.15)
        static let buttonSecondaryBorder = Color.white.opacity(0.2)
        static let secondaryText = Color(hex: "#9CA3AF")
        static let metadataText = Color(hex: "#A1A1A1")
        static let headerTint = Color(hex: "#0A0A0C")
        static let bodyText = Color(hex: "#E0E0E0")
    }

    enum CornerRadius {
        static let card: CGFloat = 12
        static let button: CGFloat = 12
        static let buttonLarge: CGFloat = 16
        static let poster: CGFloat = 16
    }

    enum Opacity {
        static let subtleFill: CGFloat = 0.05
        static let subtleBorder: CGFloat = 0.1
        static let ring: CGFloat = 0.2
        static let disabled: CGFloat = 0.3
        static let loading: CGFloat = 0.6
    }

    enum Animation {
        static let quick: TimeInterval = 0.25
        static let standard: TimeInterval = 0.3
    }

    enum IconSize {
        static let placeholder: CGFloat = 26
    }

    enum Borders {
        static let standard: CGFloat = 1
        static let thick: CGFloat = 2
    }

    enum Strings {
        static let doubleTapToViewDetails = String(localized: "accessibility.movieCard.hint")
        static let noImageAvailable = String(localized: "accessibility.poster.noImage")
        static let imageFailedToLoad = String(localized: "accessibility.poster.loadFailed")
        static let profileButtonLabel = String(localized: "accessibility.profileButton.label")
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    enum Typography {
        static let heroTitle: Font = .system(size: 36, weight: .heavy)
        static let sectionTitle: Font = .system(size: 16, weight: .bold)
        static let cardTitle: Font = .system(size: 14, weight: .semibold)
        static let caption: Font = .system(size: 10, weight: .regular)
        static let captionBold: Font = .system(size: 11, weight: .bold)
        static let metadata: Font = .system(size: 14, weight: .medium)
        static let buttonTitle: Font = .system(size: 14, weight: .bold)
        static let appTitle: Font = .system(size: 20, weight: .bold)
        static let detailSectionTitle: Font = .system(size: 18, weight: .bold)
        static let bodyText: Font = .system(size: 14, weight: .regular)
        static let detailCaption: Font = .system(size: 12, weight: .regular)
    }

    enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let heroHeightRatio: CGFloat = 0.8
        static let tabBarHeight: CGFloat = 64
        static let buttonHeight: CGFloat = 44
        static let profileAvatarSize: CGFloat = 40
        static let logoIconSize: CGFloat = 28
        static let placeholderIconSize: CGFloat = 60
    }
}
