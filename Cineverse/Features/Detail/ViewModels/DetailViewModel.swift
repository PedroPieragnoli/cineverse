//
//  DetailViewModel.swift
//  Cineverse
//

import Foundation

@MainActor
@Observable
final class DetailViewModel {
    private enum Constants {
        static let entranceStagger: Duration = .milliseconds(50)
    }

    private let repository: DetailRepository
    private let favoritesStore: FavoriteMoviesStore

    private let baseMovie: Movie

    private(set) var movieDetail: MovieDetailPayload?
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var hasLoadedInitialData = false

    private(set) var isInMyList: Bool
    private(set) var isOverviewExpanded = false

    private(set) var showsMetadataSection = false
    private(set) var showsPlayButton = false
    private(set) var showsSecondaryContent = false

    private(set) var hasStartedEntranceAnimation = false

    init(
        movie: Movie,
        repository: DetailRepository = DefaultDetailRepository.live(),
        favoritesStore: FavoriteMoviesStore = UserDefaultsFavoriteMoviesStore()
    ) {
        self.baseMovie = movie
        self.repository = repository
        self.favoritesStore = favoritesStore
        self.isInMyList = favoritesStore.contains(movie.id)
    }

    // MARK: - Derived Text

    var title: String {
        movieDetail?.title ?? baseMovie.title
    }

    var overview: String {
        movieDetail?.overview ?? baseMovie.overview
    }

    var posterURL: URL? {
        movieDetail?.posterURL ?? baseMovie.posterURL
    }

    var ratingPercentage: Int {
        movieDetail?.ratingPercentage ?? baseMovie.ratingPercentage
    }

    var ratingText: String {
        String(
            format: String(localized: "detail.metadata.scoreFormat"),
            ratingPercentage
        )
    }

    var yearRuntimeText: String {
        [releaseYear, runtimeText]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    var genreNames: [String] {
        movieDetail?.topGenres.map(\.name) ?? []
    }

    var cast: [MovieCastMember] {
        movieDetail?.cast ?? []
    }

    private var releaseYear: String? {
        movieDetail?.releaseYear ?? baseMovie.releaseYear
    }

    private var runtimeText: String? {
        guard let minutes = movieDetail?.runtimeMinutes, minutes > 0 else {
            return nil
        }
        let seconds = minutes * 60
        return DurationTextFormatter.string(
            from: seconds,
            unitsStyle: .abbreviated
        )
    }

    // MARK: - Loading

    func loadInitialData() async {
        guard !isLoading, !hasLoadedInitialData else { return }

        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            movieDetail = try await repository.fetchDetail(movieID: baseMovie.id)
            hasLoadedInitialData = true
        } catch is CancellationError {
            // CancellationError isn't user-facing
        } catch {
            self.error = error
        }
    }

    // MARK: - Actions

    func toggleMyList() {
        isInMyList = favoritesStore.toggle(baseMovie.id)
    }

    func toggleOverviewExpanded() {
        isOverviewExpanded.toggle()
    }

    // MARK: - Entrance Animation

    func startEntranceAnimation(reduceMotion: Bool) async {
        guard !hasStartedEntranceAnimation else { return }
        hasStartedEntranceAnimation = true

        if reduceMotion {
            showsMetadataSection = true
            showsPlayButton = true
            showsSecondaryContent = true
            return
        }

        showsMetadataSection = true

        await runAfterDelay(Constants.entranceStagger) {
            self.showsPlayButton = true
        }

        await runAfterDelay(Constants.entranceStagger) {
            self.showsSecondaryContent = true
        }
    }

    private func runAfterDelay(
        _ delay: Duration,
        _ action: @MainActor () -> Void
    ) async {
        guard (try? await Task.sleep(for: delay)) != nil else { return }
        action()
    }
}
