//
//  HeroLayoutMetrics.swift
//  Cineverse
//

import SwiftUI

struct HeroLayoutMetrics {
    private enum Layout {
        static let imageLift: CGFloat = 28
        static let parallaxFactorUp: CGFloat = 0.35
    }

    let rawPullDown: CGFloat
    let parallaxOffsetY: CGFloat
    let baseImageHeight: CGFloat
    let pullDownScale: CGFloat
    let pullDownCompensation: CGFloat

    init(geometry: GeometryProxy) {
        let minY = geometry.frame(in: .named(HomeCoordinateSpace.scroll)).minY
        let containerHeight = geometry.size.height
        self.init(minY: minY, containerHeight: containerHeight)
    }

    init(minY: CGFloat, containerHeight: CGFloat) {
        let scrollUp = max(0, -minY)
        let rawPullDown = max(0, minY)
        let parallaxOffsetY = scrollUp * Layout.parallaxFactorUp
        let bottomGap = containerHeight * DesignSystem.Layout.heroBottomGapRatio
        let baseImageHeight = containerHeight - bottomGap + Layout.imageLift
        let pullDownScale = 1 + (rawPullDown / max(baseImageHeight, 1))

        self.rawPullDown = rawPullDown
        self.parallaxOffsetY = parallaxOffsetY
        self.baseImageHeight = baseImageHeight
        self.pullDownScale = pullDownScale
        pullDownCompensation = -rawPullDown
    }
}
