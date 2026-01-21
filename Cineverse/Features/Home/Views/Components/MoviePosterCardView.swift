//
//  MoviePosterCardView.swift
//  Cineverse
//

import Kingfisher
import SwiftUI

struct MoviePosterCardView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let defaultWidth: CGFloat = 120
        static let heightMultiplier: CGFloat = 1.5
        static let iconSizeRatio: CGFloat = 0.2
    }

    // MARK: - Properties

    let movie: Movie
    let width: CGFloat
    var onTap: (() -> Void)?

    @State private var loadFailed = false

    init(movie: Movie, width: CGFloat = Layout.defaultWidth, onTap: (() -> Void)? = nil) {
        self.movie = movie
        self.width = width
        self.onTap = onTap
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            posterImage
                .accessibilityHidden(true)
                .frame(width: width, height: width * Layout.heightMultiplier)
                .clipShape(cardShape)
                .overlay {
                    cardShape.strokeBorder(
                        .white.opacity(DesignSystem.Opacity.subtleBorder),
                        lineWidth: DesignSystem.Borders.standard
                    )
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .onChange(of: movie.posterURL) { _, _ in
            loadFailed = false
        }
    }

    // MARK: - Shapes

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var posterImage: some View {
        if let url = movie.posterURL, !loadFailed {
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

    private var basePlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.cardBackground)
    }

    private var loadingPlaceholder: some View {
        basePlaceholder.overlay {
            ProgressView()
                .tint(.white.opacity(DesignSystem.Opacity.loading))
        }
    }

    private var fallbackPlaceholder: some View {
        basePlaceholder.overlay {
            Image(systemName: "film")
                .font(.system(size: width * Layout.iconSizeRatio))
                .foregroundStyle(.white.opacity(DesignSystem.Opacity.disabled))
                .accessibilityHidden(true)
        }
    }

    private var accessibilityDescription: String {
        let base = movie.title
        if movie.posterURL == nil {
            return "\(base), \(DesignSystem.Strings.noImageAvailable)"
        }
        if loadFailed {
            return "\(base), \(DesignSystem.Strings.imageFailedToLoad)"
        }
        return base
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Single Poster") {
    ZStack {
        Color.black.ignoresSafeArea()
        MoviePosterCardView(movie: .mock)
    }
}

#Preview("Multiple Sizes") {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 16) {
            MoviePosterCardView(movie: .mock, width: 100)
            MoviePosterCardView(movie: .mockMario, width: 120)
            MoviePosterCardView(movie: .mockShazam, width: 140)
        }
    }
}

#Preview("Missing Poster") {
    ZStack {
        Color.black.ignoresSafeArea()
        MoviePosterCardView(movie: .mockWithoutPoster)
    }
}

#Preview("Carousel Simulation") {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Movie.mockArray) { movie in
                    MoviePosterCardView(movie: movie)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
#endif
