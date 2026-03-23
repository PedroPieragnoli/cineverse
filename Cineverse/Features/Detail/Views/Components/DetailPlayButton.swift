//
//  DetailPlayButton.swift
//  Cineverse
//

import SwiftUI

struct DetailPlayButton: View {
    private enum Layout {
        static let iconSize: CGFloat = 14
        static let height: CGFloat = 48
        static let shadowOpacity: Double = 0.4
        static let shadowRadius: CGFloat = 16
        static let shadowOffsetY: CGFloat = 8
        static let hiddenOffset: CGFloat = 20
    }

    let isVisible: Bool
    let dismissInfoOpacity: CGFloat
    let entranceAnimation: Animation
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "play.fill")
                    .font(.system(size: Layout.iconSize, weight: .semibold))
                Text(String(localized: "detail.playButton.title"))
                    .font(DesignSystem.Typography.sectionTitle)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Layout.height)
            .background(buttonBackground)
        }
        .buttonStyle(.plain)
        .detailEntrance(
            isVisible: isVisible,
            dismissInfoOpacity: dismissInfoOpacity,
            hiddenOffset: Layout.hiddenOffset,
            animation: entranceAnimation
        )
        .accessibilityLabel(String(localized: "detail.playButton.accessibilityLabel"))
    }

    private var buttonBackground: some View {
        RoundedRectangle(
            cornerRadius: DesignSystem.CornerRadius.buttonLarge,
            style: .continuous
        )
        .fill(DesignSystem.Colors.primary)
        .shadow(
            color: DesignSystem.Colors.primary.opacity(Layout.shadowOpacity),
            radius: Layout.shadowRadius,
            x: 0,
            y: Layout.shadowOffsetY
        )
    }
}

#if DEBUG
#Preview("Visible") {
    DetailPlayButton(
        isVisible: true,
        dismissInfoOpacity: 1,
        entranceAnimation: .easeOut
    ) {}
    .padding()
    .background(DesignSystem.Colors.background)
}

#Preview("Hidden") {
    DetailPlayButton(
        isVisible: false,
        dismissInfoOpacity: 1,
        entranceAnimation: .easeOut
    ) {}
    .padding()
    .background(DesignSystem.Colors.background)
}
#endif
