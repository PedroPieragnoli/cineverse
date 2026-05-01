//
//  SearchBarView.swift
//  Cineverse
//

import SwiftUI

struct SearchBarView: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            searchIcon
            placeholderText
            Spacer()
        }
        .padding(.leading, DesignSystem.Spacing.md)
        .frame(height: DesignSystem.Layout.inputHeight)
        .background(containerBackground)
    }

    // MARK: - Subviews

    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: DesignSystem.Layout.iconSizeMd))
            .foregroundStyle(DesignSystem.Colors.placeholderText)
    }

    private var placeholderText: some View {
        Text(String(localized: "search.bar.placeholder"))
            .font(DesignSystem.Typography.body)
            .foregroundStyle(DesignSystem.Colors.placeholderText)
    }

    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
            .fill(Color.white.opacity(DesignSystem.Opacity.subtleBackground))
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .strokeBorder(
                        Color.white.opacity(DesignSystem.Opacity.subtleBorder),
                        lineWidth: DesignSystem.Borders.standard
                    )
            }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Idle State") {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchBarView()
            .padding(.horizontal, DesignSystem.Spacing.md)
    }
}
#endif
