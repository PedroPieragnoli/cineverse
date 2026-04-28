//
//  HomeHeaderView.swift
//  Cineverse
//

import SwiftUI

struct HomeHeaderView: View {
    private enum Layout {
        static let bottomPadding: CGFloat = 8
        static let profileRingOpacity: CGFloat = 0.1
        static let personIconOffset: CGFloat = 4
    }

    var backgroundOpacity: Double = 0
    var onProfileTapped: (() -> Void)?

    var body: some View {
        HStack {
            logoSection
            Spacer()
            profileButton
        }
        .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
        .padding(.bottom, Layout.bottomPadding)
        .background {
            headerBackground
                .ignoresSafeArea(.container, edges: .top)
        }
    }

    // MARK: - Subviews

    private var logoSection: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "film.stack")
                .font(.system(size: DesignSystem.Layout.logoIconSize))
                .foregroundStyle(DesignSystem.Colors.primary)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                .accessibilityHidden(true)

            Text("Cineverse")
                .font(DesignSystem.Typography.appTitle)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        }
    }

    private var profileButton: some View {
        Button {
            onProfileTapped?()
        } label: {
            profileAvatar
        }
        .accessibilityLabel(Text(DesignSystem.Strings.profileButtonLabel))
        .buttonStyle(.plain)
    }

    private var profileAvatar: some View {
        Circle()
            .fill(DesignSystem.Colors.surface)
            .frame(
                width: DesignSystem.Layout.profileAvatarSize,
                height: DesignSystem.Layout.profileAvatarSize
            )
            .overlay {
                ZStack {
                    Circle()
                        .strokeBorder(
                            .white.opacity(Layout.profileRingOpacity),
                            lineWidth: DesignSystem.Borders.standard
                        )

                    Image(systemName: "person.fill")
                        .font(.system(size: DesignSystem.Layout.profileAvatarSize * 0.7))
                        .foregroundStyle(DesignSystem.Colors.secondaryText)
                        .offset(y: Layout.personIconOffset)
                }
            }
    }

    private var headerBackground: some View {
        LinearGradient(
            stops: [
                .init(color: .black.opacity(1.0 * backgroundOpacity + 0.8 * (1 - backgroundOpacity)), location: 0),
                .init(color: .black.opacity(backgroundOpacity), location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Default (Transparent)") {
    ZStack {
        Color.purple.ignoresSafeArea()
        VStack {
            HomeHeaderView()
            Spacer()
        }
    }
}

#Preview("With Background") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            HomeHeaderView(backgroundOpacity: 1.0)
            Spacer()
        }
    }
}

#Preview("Scroll Transition") {
    ZStack {
        LinearGradient(
            colors: [.purple, .black],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 0) {
            HomeHeaderView(backgroundOpacity: 0.5)
            Spacer()
        }
    }
}
#endif
