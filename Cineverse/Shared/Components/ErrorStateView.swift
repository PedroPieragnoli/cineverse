//
//  ErrorStateView.swift
//  Cineverse
//

import SwiftUI

struct ErrorStateView: View {
    // MARK: - Layout Constants

    private enum Layout {
        static let buttonVerticalPadding: CGFloat = 10
        static let buttonHorizontalPadding: CGFloat = 24
    }

    // MARK: - Properties

    let configuration: Configuration
    let onRetry: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            textContent
            retryButton
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: configuration.expandsVertically ? .infinity : nil
        )
        .padding(.vertical, configuration.verticalPadding)
    }

    // MARK: - Subviews

    private var textContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            icon
            title
            subtitle
        }
        .accessibilityElement(children: .combine)
    }

    private var icon: some View {
        Image(systemName: configuration.iconName)
            .font(.system(size: configuration.iconSize))
            .foregroundStyle(configuration.iconColor)
            .accessibilityHidden(true)
    }

    private var title: some View {
        Text(String(localized: configuration.titleKey))
            .font(configuration.titleFont)
            .foregroundStyle(configuration.titleColor)
    }

    private var subtitle: some View {
        Text(String(localized: configuration.subtitleKey))
            .font(configuration.subtitleFont)
            .foregroundStyle(configuration.subtitleColor)
            .multilineTextAlignment(.center)
    }

    private var retryButton: some View {
        Button(action: onRetry) {
            Text(String(localized: configuration.retryButtonKey))
                .font(DesignSystem.Typography.buttonTitle)
                .foregroundStyle(.white)
        }
        .padding(.vertical, Layout.buttonVerticalPadding)
        .padding(.horizontal, Layout.buttonHorizontalPadding)
        .background(DesignSystem.Colors.primary)
        .clipShape(Capsule())
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Configuration

extension ErrorStateView {
    struct Configuration {
        let iconName: String
        let iconSize: CGFloat
        let iconColor: Color
        let titleKey: LocalizedStringResource
        let titleFont: Font
        let titleColor: Color
        let subtitleKey: LocalizedStringResource
        let subtitleFont: Font
        let subtitleColor: Color
        let retryButtonKey: LocalizedStringResource
        let expandsVertically: Bool
        let verticalPadding: CGFloat

        init(
            iconName: String,
            iconSize: CGFloat = DesignSystem.Layout.errorIconSize,
            iconColor: Color = DesignSystem.Colors.placeholderText
                .opacity(DesignSystem.Opacity.errorIcon),
            titleKey: LocalizedStringResource,
            titleFont: Font = DesignSystem.Typography.errorTitle,
            titleColor: Color = .white,
            subtitleKey: LocalizedStringResource,
            subtitleFont: Font = DesignSystem.Typography.errorSubtitle,
            subtitleColor: Color = DesignSystem.Colors.placeholderText,
            retryButtonKey: LocalizedStringResource,
            expandsVertically: Bool = true,
            verticalPadding: CGFloat = 0
        ) {
            self.iconName = iconName
            self.iconSize = iconSize
            self.iconColor = iconColor
            self.titleKey = titleKey
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.subtitleKey = subtitleKey
            self.subtitleFont = subtitleFont
            self.subtitleColor = subtitleColor
            self.retryButtonKey = retryButtonKey
            self.expandsVertically = expandsVertically
            self.verticalPadding = verticalPadding
        }
    }
}
