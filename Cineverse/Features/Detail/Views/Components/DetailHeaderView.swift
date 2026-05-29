//
//  DetailHeaderView.swift
//  Cineverse
//

import SwiftUI

struct DetailHeaderView: View {
    /// Intrinsic height of the header content row. Exposed so the owning
    /// screen can size content padding without duplicating the value.
    static let contentHeight: CGFloat = 56

    // MARK: - Layout Constants

    private enum Layout {
        static let buttonIconSize: CGFloat = 18
        static let tintOpacity: CGFloat = 0.95
        static let separatorAnimationDuration: TimeInterval = 0.2

        static let favoriteScaleRestValue: CGFloat = 1.0
        static let favoriteScaleUpFactor: CGFloat = 1.15
        static let favoriteScaleUpDuration: TimeInterval = 0.25
        static let favoriteScaleUpResponse: Double = 0.25
        static let favoriteScaleUpDamping: Double = 0.5
        static let favoriteSettleDuration: TimeInterval = 0.3
        static let favoriteSettleResponse: Double = 0.3
        static let favoriteSettleDamping: Double = 0.7
    }

    // MARK: - Properties

    let horizontalPadding: CGFloat

    let isFavorite: Bool
    let showsSeparator: Bool
    let contentOpacity: CGFloat

    let onBack: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                backButton
                Spacer()
                favoriteButton
            }
            .frame(height: Self.contentHeight)
            .padding(.horizontal, horizontalPadding)

            separator
        }
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    DesignSystem.Colors.headerTint
                        .opacity(Layout.tintOpacity)
                )
        }
        .opacity(contentOpacity)
    }

    // MARK: - Subviews

    private var separator: some View {
        Rectangle()
            .fill(.white.opacity(DesignSystem.Opacity.subtleBorder))
            .frame(height: DesignSystem.Borders.standard)
            .opacity(showsSeparator ? 1 : 0)
            .animation(
                .easeInOut(duration: Layout.separatorAnimationDuration),
                value: showsSeparator
            )
    }

    private var backButton: some View {
        Button(action: onBack) {
            circularHitArea(alignment: .leading) {
                Image(systemName: "chevron.backward")
                    .font(.system(
                        size: Layout.buttonIconSize,
                        weight: .bold
                    ))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "detail.header.backButton"))
    }

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            circularHitArea(alignment: .trailing) { heartIcon }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isFavorite)
        .accessibilityLabel(String(localized: "detail.header.favoriteButton"))
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(
            isFavorite
                ? String(localized: "detail.favorite.state.on")
                : String(localized: "detail.favorite.state.off")
        )
    }

    private var heartIcon: some View {
        Image(systemName: isFavorite ? "heart.fill" : "heart")
            .font(.system(size: Layout.buttonIconSize, weight: .semibold))
            .foregroundStyle(isFavorite ? DesignSystem.Colors.primary : .white)
            .keyframeAnimator(
                initialValue: Layout.favoriteScaleRestValue,
                trigger: isFavorite
            ) { content, value in
                content.scaleEffect(value)
            } keyframes: { _ in
                SpringKeyframe(
                    Layout.favoriteScaleUpFactor,
                    duration: Layout.favoriteScaleUpDuration,
                    spring: .init(
                        response: Layout.favoriteScaleUpResponse,
                        dampingRatio: Layout.favoriteScaleUpDamping
                    )
                )
                SpringKeyframe(
                    Layout.favoriteScaleRestValue,
                    duration: Layout.favoriteSettleDuration,
                    spring: .init(
                        response: Layout.favoriteSettleResponse,
                        dampingRatio: Layout.favoriteSettleDamping
                    )
                )
            }
    }

    private func circularHitArea<Content: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        content()
            .frame(
                width: DesignSystem.Layout.buttonHeight,
                height: DesignSystem.Layout.buttonHeight,
                alignment: alignment
            )
            .contentShape(Circle())
    }
}

// MARK: - Previews

#if DEBUG
private enum PreviewConstants {
    static let horizontalPadding: CGFloat = 16
}

private func previewContainer<Content: View>(
    @ViewBuilder _ content: () -> Content
) -> some View {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            content()
            Spacer()
        }
    }
}

#Preview("Default") {
    previewContainer {
        DetailHeaderView(
            horizontalPadding: PreviewConstants.horizontalPadding,
            isFavorite: false,
            showsSeparator: false,
            contentOpacity: 1,
            onBack: {},
            onToggleFavorite: {}
        )
    }
}

#Preview("Favorited & Scrolled") {
    previewContainer {
        DetailHeaderView(
            horizontalPadding: PreviewConstants.horizontalPadding,
            isFavorite: true,
            showsSeparator: true,
            contentOpacity: 1,
            onBack: {},
            onToggleFavorite: {}
        )
    }
}
#endif
