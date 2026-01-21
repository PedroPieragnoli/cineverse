//
//  HeroSectionView.swift
//  Cineverse
//

import SwiftUI

struct HeroSectionView: View {
    // MARK: - Properties

    let featuredMovie: FeaturedMovie
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
#Preview("Default") {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            HeroSectionView(featuredMovie: .mock)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("With Actions") {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            HeroSectionView(
                featuredMovie: .mock,
                onWatchTapped: { print("Watch tapped") },
                onMyListTapped: { print("My List tapped") }
            )
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Different Movie") {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView {
            HeroSectionView(featuredMovie: .mockMario)
        }
    }
    .preferredColorScheme(.dark)
}
#endif
