//
//  HeroLayoutMetricsTests.swift
//  CineverseTests
//

import SwiftUI
import Testing
@testable import Cineverse

struct HeroLayoutMetricsTests {
    @Test("Neutral scroll keeps metrics at baseline values")
    func neutralScrollBaseline() {
        let metrics = HeroLayoutMetrics(minY: 0, containerHeight: 600)

        #expect(metrics.rawPullDown == 0)
        #expect(metrics.parallaxOffsetY == 0)
        #expect(metrics.pullDownScale == 1)
        #expect(metrics.pullDownCompensation == 0)
    }

    @Test("Upward scroll applies only parallax offset")
    func upwardScrollParallaxOnly() {
        let metrics = HeroLayoutMetrics(minY: -100, containerHeight: 600)

        #expect(abs(metrics.parallaxOffsetY - 35) < 0.0001)
        #expect(metrics.rawPullDown == 0)
        #expect(metrics.pullDownScale == 1)
        #expect(metrics.pullDownCompensation == 0)
    }

    @Test("Pull-down increases scale and adds compensation")
    func pullDownIncreasesScale() {
        let metrics = HeroLayoutMetrics(minY: 120, containerHeight: 600)
        let bottomGapRatio: CGFloat = 0.10
        let expectedBaseHeight = 600 - (600 * bottomGapRatio) + 28
        let expectedScale = 1 + (120 / max(expectedBaseHeight, 1))

        #expect(metrics.rawPullDown == 120)
        #expect(metrics.pullDownCompensation == -120)
        #expect(abs(metrics.pullDownScale - expectedScale) < 0.0001)
        #expect(metrics.pullDownScale > 1)
    }

    @Test("Base image height follows layout formula")
    func baseImageHeightFormula() {
        let containerHeight: CGFloat = 500
        let metrics = HeroLayoutMetrics(minY: 0, containerHeight: containerHeight)
        let bottomGapRatio: CGFloat = 0.10
        let expected = containerHeight - (containerHeight * bottomGapRatio) + 28

        #expect(abs(metrics.baseImageHeight - expected) < 0.0001)
    }

    @Test("Zero container height stays finite and deterministic")
    func zeroContainerHeightSafety() {
        let metrics = HeroLayoutMetrics(minY: 100, containerHeight: 0)
        let expectedBaseHeight: CGFloat = 28
        let expectedScale = 1 + (100 / max(expectedBaseHeight, 1))

        #expect(abs(metrics.baseImageHeight - expectedBaseHeight) < 0.0001)
        #expect(abs(metrics.pullDownScale - expectedScale) < 0.0001)
        #expect(metrics.pullDownScale.isFinite)
    }
}
