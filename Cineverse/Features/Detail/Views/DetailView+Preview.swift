//
//  DetailView+Preview.swift
//  Cineverse
//

#if DEBUG
import SwiftUI

private struct DetailPreviewContainer: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                DetailView(
                    route: DetailRoute(movie: .mock, source: .posterCard),
                    topSafeAreaInset: geometry.safeAreaInsets.top,
                    viewModel: DetailViewModel(
                        movie: .mock,
                        repository: PreviewDetailRepository(),
                        favoritesStore: PreviewFavoriteMoviesStore()
                    )
                )
            }
        }
    }
}

private struct PreviewFavoriteMoviesStore: FavoriteMoviesStore {
    func contains(_ movieID: Int) -> Bool { false }

    @discardableResult
    func toggle(_ movieID: Int) -> Bool { true }
}

#Preview("Detail View") {
    DetailPreviewContainer()
        .preferredColorScheme(.dark)
}
#endif
