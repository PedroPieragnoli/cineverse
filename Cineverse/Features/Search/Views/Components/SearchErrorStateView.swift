//
//  SearchErrorStateView.swift
//  Cineverse
//

import SwiftUI

struct SearchErrorStateView: View {
    private enum Layout {
        static let buttonVerticalPadding: CGFloat = 10
        static let buttonHorizontalPadding: CGFloat = 24
    }

    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            icon
            title
            subtitle
            retryButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Subviews

    private var icon: some View {
        Image(systemName: "icloud.slash")
            .font(.system(size: DesignSystem.Layout.errorIconSize))
            .foregroundStyle(
                DesignSystem.Colors.placeholderText
                    .opacity(DesignSystem.Opacity.errorIcon)
            )
            .accessibilityHidden(true)
    }

    private var title: some View {
        Text(String(localized: "search.errorState.title"))
            .font(DesignSystem.Typography.errorTitle)
            .foregroundStyle(.white)
    }

    private var subtitle: some View {
        Text(String(localized: "search.errorState.subtitle"))
            .font(DesignSystem.Typography.errorSubtitle)
            .foregroundStyle(DesignSystem.Colors.placeholderText)
    }

    private var retryButton: some View {
        Button(action: onRetry) {
            Text(String(localized: "search.errorState.retryButton"))
                .font(DesignSystem.Typography.buttonTitle)
                .foregroundStyle(.white)
        }
        .padding(.vertical, Layout.buttonVerticalPadding)
        .padding(.horizontal, Layout.buttonHorizontalPadding)
        .background(DesignSystem.Colors.primary)
        .clipShape(Capsule())
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Previews

#if DEBUG
#Preview {
    SearchErrorStateView {}
        .background(DesignSystem.Colors.background)
        .preferredColorScheme(.dark)
}
#endif
