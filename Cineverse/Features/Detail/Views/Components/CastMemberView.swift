//
//  CastMemberView.swift
//  Cineverse
//

import Kingfisher
import SwiftUI

struct CastMemberView: View {
    private enum Layout {
        static let castItemWidth: CGFloat = 80
        static let avatarSize: CGFloat = 64
        static let placeholderIconSize: CGFloat = 20
        static let placeholderBackground: Color = Color(hex: "#1A1A1C")
    }

    let castMember: MovieCastMember

    var body: some View {
        VStack(spacing: 0) {
            avatar
                .frame(width: Layout.avatarSize, height: Layout.avatarSize)
                .padding(.bottom, DesignSystem.Spacing.xs)

            Text(castMember.name)
                .font(DesignSystem.Typography.captionBold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Text(castMember.character)
                .font(DesignSystem.Typography.caption)
                .foregroundStyle(DesignSystem.Colors.metadataText)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
        }
        .frame(width: Layout.castItemWidth)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Subviews

    private var avatar: some View {
        Group {
            if let profileURL = castMember.profileURL {
                KFImage(profileURL)
                    .placeholder {
                        avatarPlaceholder
                    }
                    .retry(maxCount: 2, interval: .seconds(1))
                    .fade(duration: DesignSystem.Animation.standard)
                    .resizable()
                    .scaledToFill()
            } else {
                avatarPlaceholder
            }
        }
        .clipShape(Circle())
        .overlay {
            Circle()
                .strokeBorder(
                    DesignSystem.Colors.primary.opacity(DesignSystem.Opacity.ring),
                    lineWidth: DesignSystem.Borders.thick
                )
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Layout.placeholderBackground)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: Layout.placeholderIconSize, weight: .medium))
                    .foregroundStyle(.white.opacity(DesignSystem.Opacity.disabled))
            }
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        String(
            format: String(localized: "detail.cast.member.accessibilityLabel"),
            castMember.name,
            castMember.character
        )
    }
}

// MARK: - Previews

#if DEBUG
#Preview("With Photo") {
    ZStack {
        Color.black.ignoresSafeArea()
        CastMemberView(castMember: .mock)
    }
}

#Preview("Without Photo") {
    ZStack {
        Color.black.ignoresSafeArea()
        CastMemberView(castMember: .mockWithoutPhoto)
    }
}

#Preview("Cast Row") {
    ZStack {
        Color.black.ignoresSafeArea()
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(MovieCastMember.mockArray) { member in
                    CastMemberView(castMember: member)
                }
            }
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
        }
    }
}
#endif
