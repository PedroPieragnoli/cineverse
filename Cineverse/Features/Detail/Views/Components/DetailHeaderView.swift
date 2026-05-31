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

        static let iconRestScale: CGFloat = 1.0
        static let iconPopScale: CGFloat = 1.15
        static let iconPopDuration: TimeInterval = 0.25
        static let iconPopResponse: Double = 0.25
        static let iconPopDamping: Double = 0.5
        static let iconSettleDuration: TimeInterval = 0.3
        static let iconSettleResponse: Double = 0.3
        static let iconSettleDamping: Double = 0.7
    }

    // MARK: - Properties

    let horizontalPadding: CGFloat

    let isInMyList: Bool
    let showsSeparator: Bool
    let contentOpacity: CGFloat

    let onBack: () -> Void
    let onToggleMyList: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                backButton
                Spacer()
                myListButton
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

    private var myListButton: some View {
        Button(action: onToggleMyList) {
            circularHitArea(alignment: .trailing) { myListIcon }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isInMyList)
        .accessibilityLabel(String(localized: "detail.header.myListButton"))
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(
            isInMyList
                ? String(localized: "detail.myList.state.on")
                : String(localized: "detail.myList.state.off")
        )
    }

    private var myListIcon: some View {
        Image(systemName: isInMyList ? "bookmark.fill" : "bookmark")
            .font(.system(size: Layout.buttonIconSize, weight: .semibold))
            .foregroundStyle(isInMyList ? DesignSystem.Colors.primary : .white)
            .keyframeAnimator(
                initialValue: Layout.iconRestScale,
                trigger: isInMyList
            ) { content, value in
                content.scaleEffect(value)
            } keyframes: { _ in
                SpringKeyframe(
                    Layout.iconPopScale,
                    duration: Layout.iconPopDuration,
                    spring: .init(
                        response: Layout.iconPopResponse,
                        dampingRatio: Layout.iconPopDamping
                    )
                )
                SpringKeyframe(
                    Layout.iconRestScale,
                    duration: Layout.iconSettleDuration,
                    spring: .init(
                        response: Layout.iconSettleResponse,
                        dampingRatio: Layout.iconSettleDamping
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
            isInMyList: false,
            showsSeparator: false,
            contentOpacity: 1,
            onBack: {},
            onToggleMyList: {}
        )
    }
}

#Preview("In My List & Scrolled") {
    previewContainer {
        DetailHeaderView(
            horizontalPadding: PreviewConstants.horizontalPadding,
            isInMyList: true,
            showsSeparator: true,
            contentOpacity: 1,
            onBack: {},
            onToggleMyList: {}
        )
    }
}
#endif
