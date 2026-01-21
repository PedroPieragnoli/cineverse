//
//  HeroInfoOverlayView.swift
//  Cineverse
//

import SwiftUI

struct HeroInfoOverlayView: View {
    private enum Layout {
        static let maxTitleWidth: CGFloat = 0.9
        static let descriptionLineLimit = 2
        static let buttonSpacing: CGFloat = 12
        static let contentBottomPadding: CGFloat = 40
        static let movieInfoTopSpacing: CGFloat = 100
        static let movieInfoGradientHeightRatio: CGFloat = 0.58
    }

    let featuredMovie: FeaturedMovie
    let width: CGFloat
    let height: CGFloat
    var onWatchTapped: (() -> Void)?
    var onMyListTapped: (() -> Void)?

    var body: some View {
        let contentWidth = width - 2 * DesignSystem.Layout.horizontalPadding
        return ZStack(alignment: .bottomLeading) {
            gradientOverlay
                .frame(maxWidth: .infinity)
                .frame(height: height * Layout.movieInfoGradientHeightRatio, alignment: .bottom)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .allowsHitTesting(false)

            infoContent(contentWidth: contentWidth)
                .padding(.top, Layout.movieInfoTopSpacing)
                .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
                .padding(.bottom, Layout.contentBottomPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var gradientOverlay: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .black.opacity(0.50), location: 0.33),
                .init(color: .black, location: 0.9)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func infoContent(contentWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            titleText(contentWidth: contentWidth)
            metadataRow
            descriptionText(contentWidth: contentWidth)
            actionButtons
        }
    }

    private func titleText(contentWidth: CGFloat) -> some View {
        Text(featuredMovie.movie.title)
            .font(DesignSystem.Typography.heroTitle)
            .foregroundStyle(.white)
            .lineLimit(2)
            .frame(maxWidth: contentWidth * Layout.maxTitleWidth, alignment: .leading)
            .shadow(color: .black.opacity(0.8), radius: 8, x: 0, y: 4)
    }

    private var metadataRow: some View {
        Text(featuredMovie.metadataText)
            .font(DesignSystem.Typography.metadata)
            .foregroundStyle(DesignSystem.Colors.metadataText)
            .shadow(color: .black.opacity(0.5), radius: 4)
            .accessibilityLabel(featuredMovie.accessibilityMetadataText)
    }

    private func descriptionText(contentWidth: CGFloat) -> some View {
        Text(featuredMovie.movie.overview)
            .font(DesignSystem.Typography.heroDescription)
            .foregroundStyle(DesignSystem.Colors.heroDescriptionText)
            .lineLimit(Layout.descriptionLineLimit)
            .frame(maxWidth: contentWidth * Layout.maxTitleWidth, alignment: .leading)
            .shadow(color: .black.opacity(0.5), radius: 4)
    }

    private var actionButtons: some View {
        HStack(spacing: Layout.buttonSpacing) {
            watchButton
            myListButton
        }
        .padding(.top, DesignSystem.Spacing.xs)
    }

    private var watchButton: some View {
        HeroActionButton(
            iconSystemName: "play.fill",
            titleKey: "home.heroButton.play.title",
            style: .primary
        ) {
            onWatchTapped?()
        }
    }

    private var myListButton: some View {
        HeroActionButton(
            iconSystemName: "plus",
            titleKey: "home.heroButton.myList.title",
            style: .secondary
        ) {
            onMyListTapped?()
        }
    }
}
