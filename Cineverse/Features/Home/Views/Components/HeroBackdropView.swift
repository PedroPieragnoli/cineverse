//
//  HeroBackdropView.swift
//  Cineverse
//

import Kingfisher
import SwiftUI

struct HeroBackdropView: View {
    let backdropURL: URL?
    let size: CGSize
    let baseImageHeight: CGFloat
    let parallaxOffsetY: CGFloat
    let pullDownScale: CGFloat
    let rawPullDown: CGFloat
    let pullDownCompensation: CGFloat

    @State private var loadFailed = false

    var body: some View {
        backdropImage
            .clipped()
            .padding(.bottom, -rawPullDown)
            .offset(y: pullDownCompensation)
            .onChange(of: backdropURL) { _, _ in
                loadFailed = false
            }
    }

    @ViewBuilder
    private var backdropContent: some View {
        if let url = backdropURL, !loadFailed {
            KFImage(url)
                .placeholder { loadingPlaceholder }
                .onFailure { _ in loadFailed = true }
                .retry(maxCount: 2, interval: .seconds(1))
                .fade(duration: DesignSystem.Animation.standard)
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            fallbackPlaceholder
        }
    }

    private var backdropImage: some View {
        backdropContent
            .frame(width: size.width, height: baseImageHeight)
            .scaleEffect(pullDownScale, anchor: .top)
            .frame(maxHeight: .infinity, alignment: .top)
            .offset(y: parallaxOffsetY)
    }

    private var loadingPlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.cardBackground)
            .overlay {
                ProgressView()
                    .tint(.white.opacity(DesignSystem.Opacity.loading))
            }
    }

    private var fallbackPlaceholder: some View {
        Rectangle()
            .fill(DesignSystem.Colors.cardBackground)
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: DesignSystem.Layout.placeholderIconSize))
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.disabled))
            }
            .accessibilityHidden(true)
    }
}
