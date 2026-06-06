//
//  MyListToggleState.swift
//  Cineverse
//

import SwiftUI

/// Whether a movie is saved to My List, and how that reads on screen.
///
/// Owns the two parts every My List toggle shares — the glyph and the VoiceOver
/// state announcement — so the surfaces offering the action cannot drift apart.
/// Surface-specific styling (tint, motion, haptics) stays with the surface.
enum MyListToggleState {
    case inList
    case notInList

    init(isInMyList: Bool) {
        self = isInMyList ? .inList : .notInList
    }

    var symbolName: String {
        switch self {
        case .inList: return "bookmark.fill"
        case .notInList: return "bookmark"
        }
    }

    var accessibilityValue: String {
        switch self {
        case .inList: return String(localized: "accessibility.myList.state.on")
        case .notInList: return String(localized: "accessibility.myList.state.off")
        }
    }
}

extension View {
    /// Announces the receiver as a My List toggle: adds the `.isToggle` trait and
    /// the on/off state value. The caller still supplies the accessibility label.
    ///
    /// Apply to a view exposing exactly one accessibility element, such as a `Button`.
    func myListToggleAccessibility(_ state: MyListToggleState) -> some View {
        accessibilityAddTraits(.isToggle)
            .accessibilityValue(state.accessibilityValue)
    }
}
