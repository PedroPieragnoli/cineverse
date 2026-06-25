//
//  DetailHeroSectionView.swift
//  Cineverse
//

import Kingfisher
import SwiftUI

struct DetailHeroSectionView: View {

    // MARK: - Nested Types

    struct PosterContent {
        let posterURL: URL?
        let placeholderPosterURL: URL?
        let showsHeroPoster: Bool
        let shouldUsePosterHeroTransition: Bool
    }

    struct MetadataContent {
        let title: String
        let ratingText: String
        let yearRuntimeText: String
        let accessibilityYearRuntimeText: String
        let genreNames: [String]
    }

    struct PresentationState {
        let isLoading: Bool
        let hasPayload: Bool
        let showsMetadataSection: Bool
        let dismissInfoOpacity: CGFloat
        let entranceAnimation: Animation
    }

    // MARK: - Layout

    private enum Layout {
        static let posterWidth: CGFloat = 120
        static let posterHeight: CGFloat = 180
        static let metadataHiddenOffset: CGFloat = 15
        static let titleLineLimit = 3
        static let titleMinScaleFactor: CGFloat = 0.75
        static let posterRetryMaxCount = 2
        static let posterRetryIntervalSeconds: TimeInterval = 1
        static let titleFont: Font = .system(size: 22, weight: .black)
        static let tagHorizontalPadding: CGFloat = 13
        static let tagVerticalPadding: CGFloat = 5
        static let tagKerning: CGFloat = 0.5
    }

    // MARK: - Properties

    let poster: PosterContent
    let metadata: MetadataContent
    let presentation: PresentationState

    // MARK: - Body

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            posterColumn
            animatedMetadataSection
        }
    }

    // MARK: - Poster

    private var posterColumn: some View {
        heroPoster
            .frame(width: Layout.posterWidth, height: Layout.posterHeight)
            .background(posterFrameReporter)
            .accessibilityHidden(true)
    }

    private var posterFrameReporter: some View {
        GeometryReader { geometry in
            Color.clear.preference(
                key: DetailHeroPosterFramePreferenceKey.self,
                value: geometry.frame(in: .global)
            )
        }
    }

    @ViewBuilder
    private var heroPoster: some View {
        if poster.showsHeroPoster {
            posterImage(fadesIn: !poster.shouldUsePosterHeroTransition)
        } else {
            Color.clear
        }
    }

    private func posterImage(fadesIn: Bool) -> some View {
        Group {
            if let posterURL = poster.posterURL {
                KFImage(posterURL)
                    .placeholder {
                        cachedThumbnailPlaceholder
                    }
                    .retry(
                        maxCount: Layout.posterRetryMaxCount,
                        interval: .seconds(Layout.posterRetryIntervalSeconds)
                    )
                    .fade(duration: fadesIn ? DesignSystem.Animation.standard : 0)
                    .resizable()
                    .scaledToFill()
            } else {
                emptyPosterPlaceholder
            }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.poster,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.poster,
                style: .continuous
            )
            .strokeBorder(
                .white.opacity(DesignSystem.Opacity.subtleBorder),
                lineWidth: DesignSystem.Borders.standard
            )
        }
    }

    @ViewBuilder
    private var cachedThumbnailPlaceholder: some View {
        if let placeholderPosterURL = poster.placeholderPosterURL {
            KFImage(placeholderPosterURL)
                .resizable()
                .scaledToFill()
        } else {
            emptyPosterPlaceholder
        }
    }

    private var emptyPosterPlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.surface)
            .overlay {
                Image(systemName: "film")
                    .font(.system(
                        size: DesignSystem.IconSize.placeholder,
                        weight: .medium
                    ))
                    .foregroundStyle(
                        .white.opacity(DesignSystem.Opacity.disabled)
                    )
                    .accessibilityHidden(true)
            }
    }

    // MARK: - Metadata

    private var animatedMetadataSection: some View {
        metadataSection
            .detailEntrance(
                isVisible: presentation.showsMetadataSection,
                dismissInfoOpacity: presentation.dismissInfoOpacity,
                hiddenOffset: Layout.metadataHiddenOffset,
                animation: presentation.entranceAnimation
            )
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(metadata.title)
                .font(Layout.titleFont)
                .foregroundStyle(.white)
                .lineLimit(Layout.titleLineLimit)
                .minimumScaleFactor(Layout.titleMinScaleFactor)
                .accessibilityAddTraits(.isHeader)

            Text(metadata.ratingText)
                .font(DesignSystem.Typography.buttonTitle)
                .foregroundStyle(DesignSystem.Colors.primary)

            if !metadata.yearRuntimeText.isEmpty {
                Text(metadata.yearRuntimeText)
                    .font(DesignSystem.Typography.detailCaption)
                    .foregroundStyle(DesignSystem.Colors.metadataText)
                    .accessibilityLabel(metadata.accessibilityYearRuntimeText)
            }

            genreTags
                .padding(.top, DesignSystem.Spacing.xs)

            if presentation.isLoading, !presentation.hasPayload {
                ProgressView()
                    .tint(.white.opacity(DesignSystem.Opacity.loading))
                    .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var genreTags: some View {
        if !metadata.genreNames.isEmpty {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(metadata.genreNames, id: \.self, content: genreTag)
            }
        }
    }

    private func genreTag(_ name: String) -> some View {
        Text(name.uppercased())
            .font(DesignSystem.Typography.captionBold)
            .foregroundStyle(DesignSystem.Colors.metadataText)
            .kerning(Layout.tagKerning)
            .padding(.horizontal, Layout.tagHorizontalPadding)
            .padding(.vertical, Layout.tagVerticalPadding)
            .background(genreTagBackground)
            .overlay { genreTagBorder }
    }

    private var genreTagBackground: some View {
        Capsule(style: .continuous)
            .fill(.white.opacity(DesignSystem.Opacity.subtleFill))
    }

    private var genreTagBorder: some View {
        Capsule(style: .continuous)
            .strokeBorder(
                .white.opacity(DesignSystem.Opacity.subtleBorder),
                lineWidth: DesignSystem.Borders.standard
            )
    }
}

// MARK: - Previews

#if DEBUG
private let previewEntranceAnimation: Animation = .interpolatingSpring(
    mass: 1, stiffness: 250, damping: 25, initialVelocity: 0
)

#Preview("Loaded") {
    let movie = Movie.mockAvatar
    DetailHeroSectionView(
        poster: .init(
            posterURL: movie.posterURL,
            placeholderPosterURL: nil,
            showsHeroPoster: true,
            shouldUsePosterHeroTransition: false
        ),
        metadata: .init(
            title: movie.title,
            ratingText: "\(movie.ratingPercentage)% Score",
            yearRuntimeText: "\(movie.releaseYear ?? "—") • 3h 12m",
            accessibilityYearRuntimeText: "\(movie.releaseYear ?? "—"), 3 hours, 12 minutes",
            genreNames: [
                Genre.scienceFiction.name,
                Genre.adventure.name,
                Genre.action.name
            ]
        ),
        presentation: .init(
            isLoading: false,
            hasPayload: true,
            showsMetadataSection: true,
            dismissInfoOpacity: 1,
            entranceAnimation: previewEntranceAnimation
        )
    )
    .padding()
    .background(DesignSystem.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("Loading, no payload") {
    let movie = Movie.mockWithoutPoster
    DetailHeroSectionView(
        poster: .init(
            posterURL: movie.posterURL,
            placeholderPosterURL: nil,
            showsHeroPoster: true,
            shouldUsePosterHeroTransition: false
        ),
        metadata: .init(
            title: movie.title,
            ratingText: "0% Score",
            yearRuntimeText: "",
            accessibilityYearRuntimeText: "",
            genreNames: []
        ),
        presentation: .init(
            isLoading: true,
            hasPayload: false,
            showsMetadataSection: true,
            dismissInfoOpacity: 1,
            entranceAnimation: previewEntranceAnimation
        )
    )
    .padding()
    .background(DesignSystem.Colors.background)
    .preferredColorScheme(.dark)
}

#Preview("No genres, no poster") {
    let movie = Movie.mockWithoutPoster
    DetailHeroSectionView(
        poster: .init(
            posterURL: movie.posterURL,
            placeholderPosterURL: nil,
            showsHeroPoster: true,
            shouldUsePosterHeroTransition: false
        ),
        metadata: .init(
            title: movie.title,
            ratingText: "70% Score",
            yearRuntimeText: "2020",
            accessibilityYearRuntimeText: "2020",
            genreNames: []
        ),
        presentation: .init(
            isLoading: false,
            hasPayload: true,
            showsMetadataSection: true,
            dismissInfoOpacity: 1,
            entranceAnimation: previewEntranceAnimation
        )
    )
    .padding()
    .background(DesignSystem.Colors.background)
    .preferredColorScheme(.dark)
}
#endif
