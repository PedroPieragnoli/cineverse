//
//  DetailEntranceModifier.swift
//  Cineverse
//

import SwiftUI

/// Shared staged-entrance animation used by the Detail screen sections.
/// Fades and slides content in from a hidden offset while respecting the
/// ongoing dismiss-info fade controlled by the screen.
struct DetailEntranceModifier: ViewModifier {
    let isVisible: Bool
    let dismissInfoOpacity: CGFloat
    let hiddenOffset: CGFloat
    let animation: Animation

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? dismissInfoOpacity : 0)
            .offset(y: isVisible ? 0 : hiddenOffset)
            .animation(animation, value: isVisible)
    }
}

extension View {
    func detailEntrance(
        isVisible: Bool,
        dismissInfoOpacity: CGFloat,
        hiddenOffset: CGFloat,
        animation: Animation
    ) -> some View {
        modifier(
            DetailEntranceModifier(
                isVisible: isVisible,
                dismissInfoOpacity: dismissInfoOpacity,
                hiddenOffset: hiddenOffset,
                animation: animation
            )
        )
    }
}
