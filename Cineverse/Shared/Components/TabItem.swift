//
//  TabItem.swift
//  Cineverse
//

import Foundation

enum TabItem: CaseIterable, Hashable {
    case home
    case search
    case comingSoon
    case myList

    var icon: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .comingSoon: return "calendar"
        case .myList: return "bookmark"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .comingSoon: return "calendar"
        case .myList: return "bookmark.fill"
        }
    }

    var title: String {
        switch self {
        case .home: return String(localized: "tab.home.title")
        case .search: return String(localized: "tab.search.title")
        case .comingSoon: return String(localized: "tab.comingSoon.title")
        case .myList: return String(localized: "tab.myList.title")
        }
    }
}
