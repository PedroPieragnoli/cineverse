//
//  DetailHeroPosterFramePreferenceKey.swift
//  Cineverse
//

import SwiftUI

struct DetailHeroPosterFramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect? = nil

    static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}
