//
//  HomeViewModel.swift
//  Cineverse
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private let repository: HomeRepository

    private(set) var featuredMovie: FeaturedMovie?
    private(set) var continueWatching: [ContinueWatchingItem] = []
    private(set) var trendingMovies: [Movie] = []
    private(set) var newReleases: [Movie] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var hasLoadedInitialData = false

    init(repository: HomeRepository = DefaultHomeRepository.live()) {
        self.repository = repository
    }

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
        defer { isLoading = false }

        do {
            let payload = try await repository.fetchHomePayload()
            featuredMovie = payload.featuredMovie
            continueWatching = payload.continueWatching
            trendingMovies = payload.trendingMovies
            newReleases = payload.newReleases
            hasLoadedInitialData = true
        } catch is CancellationError {
            hasLoadedInitialData = false
        } catch {
            self.error = HomeLoadError.map(error)
            hasLoadedInitialData = false
        }
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
}
