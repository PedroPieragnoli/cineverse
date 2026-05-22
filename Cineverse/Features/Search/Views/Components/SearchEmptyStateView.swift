//
//  SearchEmptyStateView.swift
//  Cineverse
//

import SwiftUI

struct SearchEmptyStateView: View {
    private enum Layout {
        static let iconSize: CGFloat = 40
    }

    var titleKey: LocalizedStringResource = "search.emptyState.title"
    var subtitleKey: LocalizedStringResource = "search.emptyState.subtitle"

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            icon
            title
            subtitle
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Subviews

    private var icon: some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: Layout.iconSize))
            .foregroundStyle(DesignSystem.Colors.secondaryText)
    }

    private var title: some View {
        Text(String(localized: titleKey))
            .font(DesignSystem.Typography.body)
            .foregroundStyle(.white)
    }

    private var subtitle: some View {
        Text(String(localized: subtitleKey))
            .font(DesignSystem.Typography.smallMetadata)
            .foregroundStyle(DesignSystem.Colors.secondaryText)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Search") {
    SearchEmptyStateView()
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}

#Preview("Genre") {
    SearchEmptyStateView(
        titleKey: "genre.results.empty.title",
        subtitleKey: "genre.results.empty.subtitle"
    )
    .background(DesignSystem.Colors.background)
    .preferredColorScheme(.dark)
}
#endif
