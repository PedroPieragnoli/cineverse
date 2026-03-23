//
//  DetailOverviewToggleVisibilityPolicy.swift
//  Cineverse
//

import CoreGraphics

enum DetailOverviewToggleVisibilityPolicy {
    private static let truncationEpsilon: CGFloat = 0.5

    static func isOverviewTruncated(
        fullHeight: CGFloat,
        collapsedHeight: CGFloat
    ) -> Bool {
        fullHeight > collapsedHeight + Self.truncationEpsilon
    }

    static func shouldShowToggle(
        isOverviewExpanded: Bool,
        isOverviewTruncated: Bool
    ) -> Bool {
        isOverviewExpanded || isOverviewTruncated
    }
}
