//
//  HomeViewModel.swift
//  Cineverse
//

import Foundation

@MainActor
@Observable
final class HomeViewModel {
    private let repository: HomeRepository
    private let favoritesStore: FavoriteMoviesStore

    private(set) var featuredMovie: FeaturedMovie? {
        didSet { refreshMyListState() }
    }

    private(set) var isFeaturedMovieInMyList = false
    private(set) var continueWatching: [ContinueWatchingItem] = []
    private(set) var trendingMovies: [Movie] = []
    private(set) var newReleases: [Movie] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var hasLoadedInitialData = false

    init(
        repository: HomeRepository = DefaultHomeRepository.live(),
        favoritesStore: FavoriteMoviesStore = UserDefaultsFavoriteMoviesStore()
    ) {
        self.repository = repository
        self.favoritesStore = favoritesStore
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
            // CancellationError isn't user-facing
        } catch {
            self.error = HomeLoadError.map(error)
        }
    }

    // MARK: - My List

    func refreshMyListState() {
        guard let featuredMovie else {
            isFeaturedMovieInMyList = false
            return
        }

        isFeaturedMovieInMyList = favoritesStore.contains(featuredMovie.id)
    }

    // MARK: - Intents

    func didTapMyList() {
        guard let featuredMovie else { return }

        isFeaturedMovieInMyList = favoritesStore.toggle(featuredMovie.id)
    }
}
