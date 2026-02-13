//
//  MainTabView.swift
//  Cineverse
//

import SwiftUI

struct MainTabView: View {
    // MARK: - Properties

    @State private var selectedTab: TabItem
    @State private var homeViewModel: HomeViewModel

    @MainActor
    init(initialTab: TabItem = .home) {
        _selectedTab = State(initialValue: initialTab)
        #if DEBUG
        _homeViewModel = State(
            initialValue: HomeViewModel(repository: PreviewHomeRepository())
        )
        #else
        _homeViewModel = State(
            initialValue: HomeViewModel(repository: DefaultHomeRepository.live())
        )
        #endif
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                NavigationStack {
                    tabContent(for: tab)
                }
                .tabItem {
                    Label(
                        tab.title,
                        systemImage: selectedTab == tab ? tab.selectedIcon : tab.icon
                    )
                    .environment(\.symbolVariants, .none)
                }
                .tag(tab)
            }
        }
        .tint(.white)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func tabContent(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView(viewModel: homeViewModel)
        case .search, .comingSoon, .myList:
            placeholderView(for: tab)
        }
    }

    private func placeholderView(for tab: TabItem) -> some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: tab.icon)
                    .font(.system(size: DesignSystem.Layout.placeholderIconSize))
                    .foregroundStyle(DesignSystem.Colors.primary)
                Text(tab.title)
                    .font(DesignSystem.Typography.heroTitle)
                    .foregroundStyle(.white)
                Text("mainTab.placeholder.comingSoon")
                    .font(DesignSystem.Typography.metadata)
                    .foregroundStyle(DesignSystem.Colors.secondaryText)
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Main Tab View") {
    MainTabView()
        .preferredColorScheme(.dark)
}

#Preview("Main Tab View - Search") {
    MainTabView(initialTab: .search)
        .preferredColorScheme(.dark)
}
#endif
