//
//  HomeViewModel.swift
//  Cineverse
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {

    var featuredMovie: FeaturedMovie?
    var continueWatching: [ContinueWatchingItem] = []
    var trendingMovies: [Movie] = []
    var newReleases: [Movie] = []
    var isLoading = false
    var error: Error?
    private(set) var hasLoadedInitialData = false

    var sections: [HomeSection] {
        [
            .continueWatching(items: continueWatching),
            .movieCarousel(
                title: String(localized: "home.sectionTitle.trending"),
                movies: trendingMovies
            ),
            .movieCarousel(
                title: String(localized: "home.sectionTitle.newReleases"),
                movies: newReleases
            )
        ]
        .filter { !$0.isEmpty }
    }

    func loadInitialData() async {
        guard !isLoading, !hasLoadedInitialData else { return }

        isLoading = true
        error = nil

        try? await Task.sleep(for: .milliseconds(500))

        loadMockData()
        hasLoadedInitialData = true

        isLoading = false
    }

    // MARK: - Intents

    func didTapWatch(_ featured: FeaturedMovie) {
        print("Watch tapped: \(featured.movie.title)")
    }

    func didTapMyList(_ featured: FeaturedMovie) {
        print("My List tapped: \(featured.movie.title)")
    }

    func didTapContinueWatching(_ item: ContinueWatchingItem) {
        print("Continue watching: \(item.movie.title)")
    }

    func didTapMovie(_ movie: Movie) {
        print("Movie tapped: \(movie.title)")
    }

    private func loadMockData() {
        #if DEBUG
        featuredMovie = .mockMario
        continueWatching = ContinueWatchingItem.mockArray
        trendingMovies = Movie.mockArray
        newReleases = Array(Movie.mockArray.reversed())
        #endif
    }
}
