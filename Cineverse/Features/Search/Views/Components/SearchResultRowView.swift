//
//  SearchResultRowView.swift
//  Cineverse
//

import Kingfisher
import SwiftUI

struct SearchResultRowView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let posterWidth: CGFloat = 75
        static let posterHeight: CGFloat = 112
        static let placeholderIconSize: CGFloat = 28
        static let maxTitleLines = 2
        static let titleTracking: CGFloat = -0.2
        static let subtitleTopSpacing: CGFloat = 6
        static let ratingTopSpacing: CGFloat = 8
        static let bottomSpacing: CGFloat = 12
    }

    // MARK: - Properties

    let item: SearchResultRowItem
    var showDivider: Bool = true
    var isSourceHidden: Bool = false
    var onTap: ((Movie, CGRect) -> Void)?

    @State private var loadFailed = false
    @State private var posterFrame: CGRect = .zero

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            Button { onTap?(item.movie, posterFrame) } label: {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    posterThumbnail
                        .onGeometryChange(for: CGRect.self) { proxy in
                            proxy.frame(in: .global)
                        } action: { frame in
                            posterFrame = frame
                        }
                        .opacity(isSourceHidden ? 0 : 1)
                    infoBlock
                    Spacer(minLength: 0)
                }
                .padding(.bottom, Layout.bottomSpacing)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityDescription)
            .accessibilityHidden(isSourceHidden)

            dividerLine
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var posterThumbnail: some View {
        if let url = item.posterURL, !loadFailed {
            KFImage(url)
                .placeholder { posterPlaceholder }
                .onFailure { _ in loadFailed = true }
                .retry(maxCount: 2, interval: .seconds(1))
                .fade(duration: DesignSystem.Animation.standard)
                .resizable()
                .scaledToFill()
                .frame(width: Layout.posterWidth, height: Layout.posterHeight)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.small,
                        style: .continuous
                    )
                )
        } else {
            posterFallback
        }
    }

    private var posterPlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.posterPlaceholder)
            .frame(width: Layout.posterWidth, height: Layout.posterHeight)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.small,
                    style: .continuous
                )
            )
    }

    private var posterFallback: some View {
        posterPlaceholder.overlay {
            Image(systemName: "film")
                .font(.system(size: Layout.placeholderIconSize))
                .foregroundStyle(DesignSystem.Colors.placeholderText)
        }
    }

    private var infoBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleText
            subtitleText
            ratingBadge
        }
    }

    private var titleText: some View {
        Text(item.title)
            .font(DesignSystem.Typography.resultTitle)
            .foregroundStyle(.white)
            .lineLimit(Layout.maxTitleLines)
            .tracking(Layout.titleTracking)
    }

    @ViewBuilder
    private var subtitleText: some View {
        if !item.subtitle.isEmpty {
            Text(item.subtitle)
                .font(DesignSystem.Typography.smallMetadata)
                .foregroundStyle(DesignSystem.Colors.placeholderText)
                .padding(.top, Layout.subtitleTopSpacing)
        }
    }

    @ViewBuilder
    private var ratingBadge: some View {
        if item.hasRating {
            Text(item.scoreText)
                .font(DesignSystem.Typography.smallMetadataBold)
                .foregroundStyle(DesignSystem.Colors.primary)
                .padding(.top, Layout.ratingTopSpacing)
        }
    }

    @ViewBuilder
    private var dividerLine: some View {
        if showDivider {
            Rectangle()
                .fill(.white.opacity(DesignSystem.Opacity.divider))
                .frame(height: DesignSystem.Borders.standard)
        }
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        let parts: [String?] = [
            item.title,
            posterStateDescription,
            item.accessibilitySubtitle.isEmpty ? nil : item.accessibilitySubtitle,
            item.hasRating ? item.accessibilityScoreText : nil
        ]
        return parts.compactMap { $0 }.joined(separator: ", ")
    }

    private var posterStateDescription: String? {
        guard item.posterURL != nil else { return DesignSystem.Strings.noImageAvailable }
        return loadFailed ? DesignSystem.Strings.imageFailedToLoad : nil
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Standard Row") {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchResultRowView(item: .mock)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("Missing Poster") {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchResultRowView(item: .mockNoPoster)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("No Divider") {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchResultRowView(item: .mock, showDivider: false)
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("List Simulation") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 0) {
            ForEach(Array(SearchResultRowItem.mockArray.enumerated()), id: \.element.id) { index, item in
                SearchResultRowView(
                    item: item,
                    showDivider: index < SearchResultRowItem.mockArray.count - 1
                )
            }
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}
#endif
