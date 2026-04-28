//
//  ContinueWatchingCardView.swift
//  Cineverse
//

import Kingfisher
import SwiftUI

struct ContinueWatchingCardView: View {
    private enum Layout {
        static let defaultWidth: CGFloat = 240
        static let aspectRatio: CGFloat = 16 / 9
        static let progressBarHeight: CGFloat = 4
        static let darkOverlayRestOpacity: Double = 0.1
        static let progressTrackOpacity: Double = 0.2
        static let progressGlowOpacity: Double = 0.8
        static let progressGlowRadius: CGFloat = 10
        static let fallbackIconWidthRatio: CGFloat = 0.15
        static let metadataHorizontalPadding: CGFloat = 2
    }

    let item: ContinueWatchingItem
    let width: CGFloat
    var onTap: (() -> Void)?

    @State private var loadFailed = false

    init(item: ContinueWatchingItem, width: CGFloat = Layout.defaultWidth, onTap: (() -> Void)? = nil) {
        self.item = item
        self.width = width
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .onChange(of: item.movie.backdropURL) {
            loadFailed = false
        }
    }

    // MARK: - Shapes

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
    }

    // MARK: - Subviews

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            thumbnailSection
            metadataSection
        }
        .frame(width: width)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    private var thumbnailSection: some View {
        ZStack(alignment: .bottom) {
            thumbnailImage
            darkOverlay
            progressBarOverlay
        }
        .aspectRatio(Layout.aspectRatio, contentMode: .fit)
        .clipShape(cardShape)
        .overlay {
            cardShape.strokeBorder(
                .white.opacity(DesignSystem.Opacity.subtleBorder),
                lineWidth: DesignSystem.Borders.standard
            )
        }
    }

    @ViewBuilder
    private var thumbnailImage: some View {
        if let url = item.movie.backdropURL, !loadFailed {
            KFImage(url)
                .placeholder { loadingPlaceholder }
                .onFailure { _ in loadFailed = true }
                .retry(maxCount: 2, interval: .seconds(1))
                .fade(duration: DesignSystem.Animation.standard)
                .resizable()
                .scaledToFill()
        } else {
            fallbackPlaceholder
        }
    }

    private var darkOverlay: some View {
        Rectangle()
            .fill(.black.opacity(Layout.darkOverlayRestOpacity))
    }

    private var loadingPlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.cardBackground)
            .overlay {
                ProgressView()
                    .tint(.white.opacity(DesignSystem.Opacity.loading))
            }
    }

    private var fallbackPlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.cardBackground)
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: width * Layout.fallbackIconWidthRatio))
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.disabled))
            }
    }

    private var progressBarOverlay: some View {
        VStack {
            Spacer()
            progressBar
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.white.opacity(Layout.progressTrackOpacity))

                Rectangle()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: geometry.size.width * item.progress)
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(Layout.progressGlowOpacity),
                        radius: Layout.progressGlowRadius
                    )
            }
        }
        .frame(height: Layout.progressBarHeight)
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(item.movie.title)
                .font(DesignSystem.Typography.cardTitle)
                .foregroundStyle(.white)
                .lineLimit(1)

            Text(item.remainingTimeText)
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(DesignSystem.Colors.secondaryText)
        }
        .padding(.horizontal, Layout.metadataHorizontalPadding)
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        let progressPercent = Int(item.progress * 100)
        let format = String(localized: "continueWatching.card.accessibilityDescription")
        return String(
            format: format,
            locale: .current,
            arguments: [item.movie.title, progressPercent, item.remainingTimeAccessibilityText]
        )
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Single Card") {
    ZStack {
        Color.black.ignoresSafeArea()
        ContinueWatchingCardView(item: .mock)
    }
}

#Preview("Multiple Cards") {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 16) {
            ContinueWatchingCardView(item: .mock, width: 200)
            ContinueWatchingCardView(
                item: ContinueWatchingItem(
                    movie: .mockMario,
                    progress: 0.75,
                    remainingSeconds: 20 * 60
                ),
                width: 200
            )
        }
    }
}

#Preview("Carousel Simulation") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Continue Watching")
                    .font(DesignSystem.Typography.sectionTitle)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ContinueWatchingItem.mockArray) { item in
                        ContinueWatchingCardView(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
#endif
