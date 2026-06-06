//
//  HeroActionButton.swift
//  Cineverse
//

import SwiftUI

enum HeroActionButtonStyle {
    case primary
    case secondary
}

/// A hero call-to-action button.
///
/// `Button` merges the icon and title into a **single** accessibility element
/// labelled by `titleKey`, so callers can layer state onto it from outside —
/// see `View.myListToggleAccessibility(_:)`. Keep it to one element.
struct HeroActionButton: View {
    let iconSystemName: String
    let titleKey: LocalizedStringKey
    let style: HeroActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            buttonContainer
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(Text(titleKey))
    }

    private var buttonContainer: some View {
        buttonLabel
            .font(DesignSystem.Typography.buttonTitle)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: DesignSystem.Layout.buttonHeight)
            .background(backgroundColor)
            .clipShape(buttonShape)
            .overlay {
                secondaryBorderOverlay
            }
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowYOffset)
    }

    private var buttonLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: iconSystemName)
                .font(.system(size: 20))
            Text(titleKey)
        }
    }

    private var buttonShape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: DesignSystem.CornerRadius.button,
            style: .continuous
        )
    }

    @ViewBuilder
    private var secondaryBorderOverlay: some View {
        if style == .secondary {
            buttonShape
                .strokeBorder(
                    DesignSystem.Colors.buttonSecondaryBorder,
                    lineWidth: DesignSystem.Borders.standard
                )
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.primary
        case .secondary:
            return DesignSystem.Colors.buttonSecondaryBackground
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary:
            return DesignSystem.Colors.primary.opacity(0.3)
        case .secondary:
            return .clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .primary:
            return 8
        case .secondary:
            return 0
        }
    }

    private var shadowYOffset: CGFloat {
        switch style {
        case .primary:
            return 4
        case .secondary:
            return 0
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
