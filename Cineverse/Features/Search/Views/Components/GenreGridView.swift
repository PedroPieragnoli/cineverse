//
//  GenreGridView.swift
//  Cineverse
//

import SwiftUI

struct GenreGridView: View {
    let items: [GenreGradientItem]

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
            ForEach(items) { item in
                GenreCardView(item: item)
            }
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Genre Grid") {
    ScrollView {
        GenreGridView(items: GenreGradientMapper.map(SearchGenreMocks.all))
    }
    .background(Color.black)
}
#endif
