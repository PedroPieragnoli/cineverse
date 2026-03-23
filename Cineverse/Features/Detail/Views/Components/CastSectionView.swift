//
//  CastSectionView.swift
//  Cineverse
//

import SwiftUI

struct CastSectionView: View {
    private enum Layout {
        static let hiddenOffset: CGFloat = 10
    }

    let cast: [MovieCastMember]
    let isVisible: Bool
    let dismissInfoOpacity: CGFloat
    let entranceAnimation: Animation

    var body: some View {
        if !cast.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                sectionTitle
                castScrollContent
            }
            .detailEntrance(
                isVisible: isVisible,
                dismissInfoOpacity: dismissInfoOpacity,
                hiddenOffset: Layout.hiddenOffset,
                animation: entranceAnimation
            )
        }
    }

    // MARK: - Subviews

    private var sectionTitle: some View {
        Text(String(localized: "detail.cast.title"))
            .font(DesignSystem.Typography.detailSectionTitle)
            .foregroundStyle(.white)
    }

    private var castScrollContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.md) {
                ForEach(cast) { castMember in
                    CastMemberView(castMember: castMember)
                }
            }
            .padding(.trailing, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Cast Section") {
    CastSectionView(
        cast: MovieCastMember.mockArray,
        isVisible: true,
        dismissInfoOpacity: 1,
        entranceAnimation: .easeInOut(duration: DesignSystem.Animation.standard)
    )
    .background(.black)
}

#Preview("Empty Cast") {
    CastSectionView(
        cast: [],
        isVisible: true,
        dismissInfoOpacity: 1,
        entranceAnimation: .easeInOut(duration: DesignSystem.Animation.standard)
    )
    .background(.black)
}
#endif
