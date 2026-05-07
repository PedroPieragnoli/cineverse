//
//  ErrorStateView+Search.swift
//  Cineverse
//

import SwiftUI

extension ErrorStateView.Configuration {
    static let searchError = ErrorStateView.Configuration(
        iconName: "icloud.slash",
        titleKey: "search.errorState.title",
        subtitleKey: "search.errorState.subtitle",
        retryButtonKey: "search.errorState.retryButton"
    )

    static let genreError = ErrorStateView.Configuration(
        iconName: "exclamationmark.triangle",
        iconSize: DesignSystem.Layout.compactErrorIconSize,
        titleKey: "search.genreError.title",
        subtitleKey: "search.genreError.subtitle",
        retryButtonKey: "search.genreError.retryButton",
        expandsVertically: false,
        verticalPadding: DesignSystem.Spacing.xxl
    )
}

// MARK: - Previews

#if DEBUG
#Preview("Search Error") {
    ErrorStateView(configuration: .searchError) {}
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}

#Preview("Genre Error") {
    ErrorStateView(configuration: .genreError) {}
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}
#endif
