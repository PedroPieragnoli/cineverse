//
//  SearchEmptyStateView.swift
//  Cineverse
//

import SwiftUI

struct SearchEmptyStateView: View {
    private enum Layout {
        static let iconSize: CGFloat = 40
    }

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
        Text(String(localized: "search.emptyState.title"))
            .font(DesignSystem.Typography.body)
            .foregroundStyle(.white)
    }

    private var subtitle: some View {
        Text(String(localized: "search.emptyState.subtitle"))
            .font(DesignSystem.Typography.smallMetadata)
            .foregroundStyle(DesignSystem.Colors.secondaryText)
    }
}

// MARK: - Previews

#if DEBUG
#Preview {
    SearchEmptyStateView()
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}
#endif
