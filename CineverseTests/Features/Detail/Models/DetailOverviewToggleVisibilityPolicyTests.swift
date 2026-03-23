//
//  DetailOverviewToggleVisibilityPolicyTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

struct DetailOverviewToggleVisibilityPolicyTests {

    // MARK: - shouldShowToggle

    @Test("overview toggle is hidden when synopsis is not truncated and not expanded")
    func overviewToggleHiddenWhenNotTruncated() {
        let shouldShow = DetailOverviewToggleVisibilityPolicy.shouldShowToggle(
            isOverviewExpanded: false,
            isOverviewTruncated: false
        )

        #expect(!shouldShow)
    }

    @Test("overview toggle is visible as read more when synopsis is truncated")
    func overviewToggleVisibleWhenTruncated() {
        let shouldShow = DetailOverviewToggleVisibilityPolicy.shouldShowToggle(
            isOverviewExpanded: false,
            isOverviewTruncated: true
        )

        #expect(shouldShow)
    }

    @Test("overview toggle stays visible as show less when expanded")
    func overviewToggleVisibleWhenExpanded() {
        let shouldShow = DetailOverviewToggleVisibilityPolicy.shouldShowToggle(
            isOverviewExpanded: true,
            isOverviewTruncated: true
        )

        #expect(shouldShow)
    }

    @Test("overview toggle stays visible when expanded even if not truncated")
    func overviewToggleVisibleWhenExpandedAndNotTruncated() {
        let shouldShow = DetailOverviewToggleVisibilityPolicy.shouldShowToggle(
            isOverviewExpanded: true,
            isOverviewTruncated: false
        )

        #expect(shouldShow)
    }

    // MARK: - isOverviewTruncated

    @Test("overview is truncated when full height exceeds collapsed height plus epsilon")
    func overviewTruncatedAboveEpsilon() {
        let isTruncated = DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: 101,
            collapsedHeight: 100
        )

        #expect(isTruncated)
    }

    @Test("overview is not truncated when full height equals collapsed height")
    func overviewNotTruncatedWhenEqual() {
        let isTruncated = DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: 100,
            collapsedHeight: 100
        )

        #expect(!isTruncated)
    }

    @Test("overview is not truncated within the epsilon tolerance")
    func overviewNotTruncatedWithinEpsilon() {
        let isTruncated = DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: 100.4,
            collapsedHeight: 100
        )

        #expect(!isTruncated)
    }

    @Test("overview is not truncated exactly at the epsilon boundary")
    func overviewNotTruncatedAtEpsilonBoundary() {
        let isTruncated = DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: 100.5,
            collapsedHeight: 100
        )

        #expect(!isTruncated)
    }

    @Test("overview is truncated just past the epsilon boundary")
    func overviewTruncatedJustPastEpsilon() {
        let isTruncated = DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: 100.6,
            collapsedHeight: 100
        )

        #expect(isTruncated)
    }

    @Test("overview is not truncated when full height is below collapsed height")
    func overviewNotTruncatedWhenFullSmallerThanCollapsed() {
        let isTruncated = DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: 50,
            collapsedHeight: 100
        )

        #expect(!isTruncated)
    }
}
