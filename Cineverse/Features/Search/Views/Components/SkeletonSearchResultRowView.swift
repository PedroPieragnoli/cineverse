//
//  SkeletonSearchResultRowView.swift
//  Cineverse
//

import SwiftUI

struct SkeletonSearchResultRowView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let posterWidth: CGFloat = 75
        static let posterHeight: CGFloat = 112
        static let titleLineHeight: CGFloat = 12
        static let metaLineHeight: CGFloat = 10
        static let titleLine1WidthRatio: CGFloat = 0.65
        static let titleLine2WidthRatio: CGFloat = 0.40
        static let metaLineWidthRatio: CGFloat = 0.30
        static let lineSpacing: CGFloat = 8
        static let bottomSpacing: CGFloat = 12
        static let posterDelay: TimeInterval = 0
        static let titleDelay: TimeInterval = 0.1
        static let metaDelay: TimeInterval = 0.2
    }

    // MARK: - Properties

    var showDivider: Bool = true

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                posterPlaceholder
                textPlaceholders
                Spacer(minLength: 0)
            }
            .padding(.bottom, Layout.bottomSpacing)

            dividerLine
        }
        .accessibilityHidden(true)
    }

    // MARK: - Subviews

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
            .fill(DesignSystem.Colors.posterPlaceholder)
            .frame(width: Layout.posterWidth, height: Layout.posterHeight)
            .shimmer(delay: Layout.posterDelay)
    }

    private var textPlaceholders: some View {
        VStack(alignment: .leading, spacing: Layout.lineSpacing) {
            placeholderLine(
                widthFraction: Layout.titleLine1WidthRatio,
                height: Layout.titleLineHeight,
                delay: Layout.titleDelay
            )
            placeholderLine(
                widthFraction: Layout.titleLine2WidthRatio,
                height: Layout.titleLineHeight,
                delay: Layout.titleDelay
            )
            placeholderLine(
                widthFraction: Layout.metaLineWidthRatio,
                height: Layout.metaLineHeight,
                delay: Layout.metaDelay
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func placeholderLine(
        widthFraction: CGFloat,
        height: CGFloat,
        delay: TimeInterval
    ) -> some View {
        GeometryReader { proxy in
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.skeleton,
                style: .continuous
            )
            .fill(DesignSystem.Colors.posterPlaceholder)
            .frame(width: proxy.size.width * widthFraction, height: height)
        }
        .frame(height: height)
        .shimmer(delay: delay)
    }

    @ViewBuilder
    private var dividerLine: some View {
        if showDivider {
            Rectangle()
                .fill(.white.opacity(DesignSystem.Opacity.divider))
                .frame(height: DesignSystem.Borders.standard)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Single Row") {
    ZStack {
        Color.black.ignoresSafeArea()
        SkeletonSearchResultRowView()
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("No Divider") {
    ZStack {
        Color.black.ignoresSafeArea()
        SkeletonSearchResultRowView(showDivider: false)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("Loading List (4 Rows)") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { index in
                SkeletonSearchResultRowView(showDivider: index < 3)
            }
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("Side by Side") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading) {
                Text("Skeleton").font(.caption).foregroundStyle(.gray)
                SkeletonSearchResultRowView(showDivider: false)
            }
            VStack(alignment: .leading) {
                Text("Real Row").font(.caption).foregroundStyle(.gray)
                SearchResultRowView(item: .mock, showDivider: false)
            }
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}
#endif
