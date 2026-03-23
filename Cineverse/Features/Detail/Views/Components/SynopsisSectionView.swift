//
//  SynopsisSectionView.swift
//  Cineverse
//

import SwiftUI

struct SynopsisSectionView: View {
    private enum HeightType: Hashable {
        case collapsed
        case full
    }

    private struct HeightsPreferenceKey: PreferenceKey {
        static let defaultValue: [HeightType: CGFloat] = [:]

        static func reduce(
            value: inout [HeightType: CGFloat],
            nextValue: () -> [HeightType: CGFloat]
        ) {
            value.merge(nextValue()) { _, new in new }
        }
    }

    private enum Layout {
        static let lineSpacing: CGFloat = 4
        static let collapsedLineLimit: Int = 4
        static let hiddenOffset: CGFloat = 10
        static let measurementOverlayOpacity: CGFloat = 0.001
    }

    let overview: String
    let isOverviewExpanded: Bool
    let isVisible: Bool
    let dismissInfoOpacity: CGFloat
    let entranceAnimation: Animation
    let onToggleExpanded: () -> Void

    @State private var collapsedHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text("detail.synopsis.title")
                .font(DesignSystem.Typography.detailSectionTitle)
                .foregroundStyle(.white)

            overviewText

            if shouldShowOverviewToggle {
                toggleButton
            }
        }
        .detailEntrance(
            isVisible: isVisible,
            dismissInfoOpacity: dismissInfoOpacity,
            hiddenOffset: Layout.hiddenOffset,
            animation: entranceAnimation
        )
    }

    // MARK: - Subviews

    private var overviewText: some View {
        styledOverview(lineLimit: isOverviewExpanded ? nil : Layout.collapsedLineLimit)
            .foregroundStyle(DesignSystem.Colors.bodyText)
            .overlay(alignment: .topLeading) {
                overviewMeasurements
            }
            .onPreferenceChange(HeightsPreferenceKey.self) { heights in
                if let height = heights[.collapsed] {
                    collapsedHeight = height
                }
                if let height = heights[.full] {
                    fullHeight = height
                }
            }
    }

    private var toggleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: DesignSystem.Animation.quick)) {
                onToggleExpanded()
            }
        } label: {
            Text(toggleTitle)
                .font(DesignSystem.Typography.cardTitle)
                .foregroundStyle(DesignSystem.Colors.primary)
        }
        .buttonStyle(.plain)
    }

    private var overviewMeasurements: some View {
        VStack(spacing: 0) {
            overviewMeasurementText(
                lineLimit: Layout.collapsedLineLimit,
                as: .collapsed
            )
            overviewMeasurementText(lineLimit: nil, as: .full)
        }
        .opacity(Layout.measurementOverlayOpacity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func styledOverview(lineLimit: Int?) -> some View {
        Text(overview)
            .font(DesignSystem.Typography.bodyText)
            .lineSpacing(Layout.lineSpacing)
            .lineLimit(lineLimit)
    }

    private func overviewMeasurementText(
        lineLimit: Int?,
        as kind: HeightType
    ) -> some View {
        styledOverview(lineLimit: lineLimit)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: HeightsPreferenceKey.self,
                        value: [kind: geometry.size.height]
                    )
                }
            }
    }

    private var toggleTitle: LocalizedStringKey {
        isOverviewExpanded ? "detail.synopsis.showLess" : "detail.synopsis.readMore"
    }

    private var isOverviewTruncated: Bool {
        DetailOverviewToggleVisibilityPolicy.isOverviewTruncated(
            fullHeight: fullHeight,
            collapsedHeight: collapsedHeight
        )
    }

    private var shouldShowOverviewToggle: Bool {
        DetailOverviewToggleVisibilityPolicy.shouldShowToggle(
            isOverviewExpanded: isOverviewExpanded,
            isOverviewTruncated: isOverviewTruncated
        )
    }
}

#if DEBUG
private let previewLongSynopsis = """
A young programmer discovers an ancient codebase that holds the key to a forgotten civilization. \
As they decipher its layers, the line between simulation and reality begins to blur, forcing them \
to confront questions about identity, agency, and what it means to truly understand a system.
"""

private let previewShortSynopsis = "A brief tale told in just enough words."

private let previewEntranceAnimation: Animation =
    .easeInOut(duration: DesignSystem.Animation.standard)

#Preview("Long synopsis, collapsed") {
    SynopsisSectionView(
        overview: previewLongSynopsis,
        isOverviewExpanded: false,
        isVisible: true,
        dismissInfoOpacity: 1,
        entranceAnimation: previewEntranceAnimation
    ) {}
    .padding()
    .background(Color.black)
}

#Preview("Long synopsis, expanded") {
    SynopsisSectionView(
        overview: previewLongSynopsis,
        isOverviewExpanded: true,
        isVisible: true,
        dismissInfoOpacity: 1,
        entranceAnimation: previewEntranceAnimation
    ) {}
    .padding()
    .background(Color.black)
}

#Preview("Short synopsis (no toggle)") {
    SynopsisSectionView(
        overview: previewShortSynopsis,
        isOverviewExpanded: false,
        isVisible: true,
        dismissInfoOpacity: 1,
        entranceAnimation: previewEntranceAnimation
    ) {}
    .padding()
    .background(Color.black)
}
#endif
