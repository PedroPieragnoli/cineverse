//
//  CineverseApp.swift
//  Cineverse
//

import SwiftUI
import UIKit

@main
struct CineverseApp: App {
    init() {
        Self.configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
    }

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
