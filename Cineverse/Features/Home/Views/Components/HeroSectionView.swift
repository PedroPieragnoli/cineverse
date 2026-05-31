//
//  HeroSectionView.swift
//  Cineverse
//

import SwiftUI

struct HeroSectionView: View {
    // MARK: - Properties

    let featuredMovie: FeaturedMovie
    let isInMyList: Bool
    var onWatchTapped: (() -> Void)?
    var onMyListTapped: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            let metrics = HeroLayoutMetrics(geometry: geometry)

            ZStack(alignment: .bottomLeading) {
                HeroBackdropView(
                    backdropURL: featuredMovie.movie.backdropURL,
                    size: geometry.size,
                    baseImageHeight: metrics.baseImageHeight,
                    parallaxOffsetY: metrics.parallaxOffsetY,
                    pullDownScale: metrics.pullDownScale,
                    rawPullDown: metrics.rawPullDown,
                    pullDownCompensation: metrics.pullDownCompensation
                )

                HeroInfoOverlayView(
                    featuredMovie: featuredMovie,
                    width: geometry.size.width,
                    height: geometry.size.height,
                    isInMyList: isInMyList,
                    onWatchTapped: onWatchTapped,
                    onMyListTapped: onMyListTapped
                )
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
        }
    }
}

// MARK: - Previews

#if DEBUG
private func previewContainer<Content: View>(
    @ViewBuilder _ content: () -> Content
) -> some View {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            content()
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Default") {
    previewContainer {
        HeroSectionView(featuredMovie: .mock, isInMyList: false)
    }
}

#Preview("With Actions") {
    previewContainer {
        HeroSectionView(
            featuredMovie: .mock,
            isInMyList: false,
            onWatchTapped: { print("Watch tapped") },
            onMyListTapped: { print("My List tapped") }
        )
    }
}

#Preview("In My List") {
    previewContainer {
        HeroSectionView(featuredMovie: .mock, isInMyList: true)
    }
}

#Preview("Different Movie") {
    previewContainer {
        HeroSectionView(featuredMovie: .mockMario, isInMyList: false)
    }
}
#endif
