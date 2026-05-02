//
//  SearchBarView.swift
//  Cineverse
//

import SwiftUI

struct SearchBarView: View {
    private enum Layout {
        static let clearIconSize: CGFloat = 10
    }

    @Binding var text: String
    var onCancel: () -> Void
    @FocusState private var isFocused: Bool
    @State private var showsCancelButton = false

    private var isActive: Bool { isFocused || !text.isEmpty }
    private var showsClearButton: Bool { !text.isEmpty }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            searchBarContainer
            if showsCancelButton { cancelButton }
        }
        .onChange(of: isFocused) {
            withAnimation(.easeInOut(duration: DesignSystem.Animation.standard)) {
                showsCancelButton = isFocused
            }
        }
    }

    // MARK: - Subviews

    private var searchBarContainer: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            searchIcon
            textField
            if showsClearButton { clearButton }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .frame(height: DesignSystem.Layout.inputHeight)
        .background(containerBackground)
    }

    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .font(.system(size: DesignSystem.Layout.iconSizeMd))
            .foregroundStyle(DesignSystem.Colors.placeholderText)
    }

    private var textField: some View {
        TextField(
            String(localized: "search.bar.placeholder"),
            text: $text
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .font(DesignSystem.Typography.body)
        .foregroundStyle(.white)
        .tint(DesignSystem.Colors.primary)
        .focused($isFocused)
    }

    private var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: Layout.clearIconSize, weight: .bold))
                .foregroundStyle(DesignSystem.Colors.background)
                .frame(
                    width: DesignSystem.Layout.iconSizeMd,
                    height: DesignSystem.Layout.iconSizeMd
                )
                .background(DesignSystem.Colors.placeholderText, in: Circle())
        }
        .buttonStyle(.plain)
    }

    private var cancelButton: some View {
        Button {
            onCancel()
            isFocused = false
        } label: {
            Text(String(localized: "search.bar.cancel"))
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.primary)
        }
        .buttonStyle(.plain)
        .transition(.opacity)
    }

    // MARK: - Shapes

    private var containerBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
            .fill(Color.white.opacity(
                isActive
                    ? DesignSystem.Opacity.focusedBackground
                    : DesignSystem.Opacity.subtleBackground
            ))
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.card, style: .continuous)
                    .strokeBorder(
                        isActive
                            ? DesignSystem.Colors.primary.opacity(DesignSystem.Opacity.focusedBorder)
                            : Color.white.opacity(DesignSystem.Opacity.subtleBorder),
                        lineWidth: DesignSystem.Borders.standard
                    )
            }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Idle State") {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchBarView(text: .constant("")) {}
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}

#Preview("Typing State") {
    ZStack {
        Color.black.ignoresSafeArea()
        SearchBarView(text: .constant("Interstellar")) {}
            .padding(.horizontal, DesignSystem.Layout.horizontalPadding)
    }
}
#endif
