import Kingfisher
import SwiftUI

struct MainTabView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var selectedTab: TabItem
    @State private var homeViewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var detailCoordinator = DetailHeroCoordinator()
    @State private var heroAnimator = DetailHeroAnimator()

    private let searchRepository: SearchRepository

    @MainActor
    init(
        initialTab: TabItem = .home,
        repository: HomeRepository = DefaultHomeRepository.live(),
        searchRepository: SearchRepository = DefaultSearchRepository.live()
    ) {
        _selectedTab = State(initialValue: initialTab)
        _homeViewModel = State(initialValue: HomeViewModel(repository: repository))
        _searchViewModel = State(initialValue: SearchViewModel(repository: searchRepository))
        self.searchRepository = searchRepository
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                TabView(selection: $selectedTab) {
                    ForEach(TabItem.allCases, id: \.self) { tab in
                        tabRoot(for: tab)
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
                .allowsHitTesting(!detailCoordinator.isDetailPresented)

                detailOverlay(
                    containerFrame: geometry.frame(in: .global),
                    topSafeAreaInset: geometry.safeAreaInsets.top
                )
            }
        }
        .tint(.white)
        .onDisappear {
            heroAnimator.cancelAll()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func tabRoot(for tab: TabItem) -> some View {
        switch tab {
        case .home:
            homeTabRoot
        case .search:
            NavigationStack {
                SearchView(
                    viewModel: searchViewModel,
                    hiddenTransitionSourceID: detailCoordinator.hiddenTransitionSourceID,
                    onDetailRequested: handleDetailRequested
                )
                .navigationDestination(for: GenreResultsRoute.self) { route in
                    GenreResultsView(
                        genre: route.genre,
                        repository: searchRepository,
                        gradient: route.gradient,
                        hiddenTransitionSourceID: detailCoordinator.hiddenTransitionSourceID,
                        onDetailRequested: handleDetailRequested
                    )
                }
            }
        case .comingSoon, .myList:
            NavigationStack {
                placeholderView(for: tab)
            }
        }
    }

    private var homeTabRoot: some View {
        HomeView(
            viewModel: homeViewModel,
            hiddenTransitionSourceID: detailCoordinator.hiddenTransitionSourceID,
            onDetailRequested: handleDetailRequested
        )
    }

    @ViewBuilder
    private func detailOverlay(
        containerFrame: CGRect,
        topSafeAreaInset: CGFloat
    ) -> some View {
        if detailCoordinator.isDetailPresented {
            ZStack {
                if let activeRoute = detailCoordinator.activeRoute {
                    DetailView(
                        route: activeRoute,
                        topSafeAreaInset: topSafeAreaInset,
                        showsHeroPoster: detailCoordinator.showsDetailPoster,
                        revealOpacity: heroAnimator.detailRevealOpacity,
                        entranceToken: heroAnimator.detailEntranceToken,
                        onPosterFrameChanged: handleDetailPosterFrameChange,
                        onStateChange: handleDetailSwipeDismissStateChange,
                        onCloseRequested: handleDetailCloseRequested,
                        onScheduleDismissLeadIn: heroAnimator.scheduleDismissLeadIn(perform:)
                    )
                    .allowsHitTesting(detailCoordinator.phase == .detailVisible)
                    .zIndex(1)
                }

                heroOverlayView(containerFrame: containerFrame)
            }
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

// MARK: - Handlers

extension MainTabView {
    @MainActor
    private func handleDetailRequested(_ route: DetailRoute) {
        if let posterURL = route.movie.posterURL {
            KingfisherManager.shared.retrieveImage(with: posterURL) { _ in }
        }

        let useHero = shouldUseHeroTransition(for: route)
        guard detailCoordinator.beginOpen(route: route, useHero: useHero) else {
            return
        }

        heroAnimator.beginOpening(
            useHero: useHero,
            payload: openingPayload(for: route, useHero: useHero)
        )
    }

    @MainActor
    private func handleDetailPosterFrameChange(_ frame: CGRect?) {
        let isReadyForHeroLanding = detailCoordinator.phase == .openingHero
            && heroAnimator.isAwaitingOpeningDestinationFrame
        guard isReadyForHeroLanding, let frame else {
            return
        }

        _ = heroAnimator.consumePosterFrameAwaiting()
        heroAnimator.scheduleDetailReveal(after: DetailHeroAnimator.Constants.heroInfoLeadInDelay)
        heroAnimator.animateHero(
            to: frame,
            targetCornerRadius: DesignSystem.CornerRadius.poster,
            kind: .presenting,
            reduceMotion: reduceMotion
        ) {
            detailCoordinator.completeOpenHero()
            heroAnimator.clearOverlay()
        }
    }

    @MainActor
    private func handleDetailCloseRequested(_ transition: DetailDismissTransition?) {
        let useHero = transition != nil
        guard detailCoordinator.beginClose(useHero: useHero) else {
            return
        }

        guard let transition else {
            heroAnimator.beginClosing(transitionPayload: nil)
            return
        }

        let sourceCornerRadius = detailCoordinator.activeRoute?.sourceCornerRadius
            ?? DesignSystem.CornerRadius.poster
        heroAnimator.beginClosing(
            transitionPayload: DetailHeroAnimator.HeroOverlayPayload(
                posterURL: transition.posterURL,
                currentFrame: transition.startFrame,
                currentCornerRadius: DesignSystem.CornerRadius.poster
            )
        )
        detailCoordinator.handoffClosingHeroToOverlay()
        heroAnimator.animateHero(
            to: transition.endFrame,
            targetCornerRadius: sourceCornerRadius,
            kind: .dismissing,
            reduceMotion: reduceMotion
        ) {
            detailCoordinator.completeCloseHero()
            heroAnimator.clearOverlay()
            heroAnimator.detailRevealOpacity = 0
        }
    }

    @MainActor
    private func handleDetailSwipeDismissStateChange(_ state: SwipeDismissState) {
        switch state {
        case .began:
            heroAnimator.clearOverlay(cancelAnimation: true)
            detailCoordinator.beginInteractiveDismiss()
        case .cancelled:
            detailCoordinator.cancelInteractiveDismiss()
        case .committed:
            detailCoordinator.beginInteractiveDismiss()
        }
    }

    private func shouldUseHeroTransition(for route: DetailRoute) -> Bool {
        DetailPosterHeroTransitionPolicy.isEnabled(
            source: route.source,
            sourcePosterFrame: route.sourcePosterFrame,
            reduceMotion: reduceMotion
        )
    }

    private func openingPayload(
        for route: DetailRoute,
        useHero: Bool
    ) -> DetailHeroAnimator.HeroOverlayPayload? {
        guard useHero, let sourceFrame = route.sourcePosterFrame else {
            return nil
        }
        return DetailHeroAnimator.HeroOverlayPayload(
            posterURL: route.sourcePosterURL ?? route.movie.posterURL,
            currentFrame: sourceFrame,
            currentCornerRadius: route.sourceCornerRadius ?? DesignSystem.CornerRadius.poster
        )
    }
}

// MARK: - Hero overlay view

extension MainTabView {
    @ViewBuilder
    private func heroOverlayView(containerFrame: CGRect) -> some View {
        if let payload = heroAnimator.heroOverlayPayload {
            let shape = RoundedRectangle(cornerRadius: payload.currentCornerRadius, style: .continuous)
            heroOverlayContent(posterURL: payload.posterURL)
                .frame(
                    width: payload.currentFrame.width,
                    height: payload.currentFrame.height
                )
                .clipShape(shape)
                .overlay {
                    shape.strokeBorder(
                        .white.opacity(DesignSystem.Opacity.subtleBorder),
                        lineWidth: DesignSystem.Borders.standard
                    )
                }
                .position(
                    x: payload.currentFrame.midX - containerFrame.minX,
                    y: payload.currentFrame.midY - containerFrame.minY
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .zIndex(10)
        }
    }

    @ViewBuilder
    private func heroOverlayContent(posterURL: URL?) -> some View {
        if let posterURL {
            if let cachedPoster = ImageCache.default.retrieveImageInMemoryCache(forKey: posterURL.cacheKey) {
                Image(uiImage: cachedPoster)
                    .resizable()
                    .scaledToFill()
            } else {
                KFImage(posterURL)
                    .resizable()
                    .scaledToFill()
            }
        } else {
            Rectangle()
                .fill(DesignSystem.Colors.surface)
                .overlay {
                    Image(systemName: "film")
                        .font(.system(size: DesignSystem.IconSize.placeholder, weight: .medium))
                        .foregroundStyle(.white.opacity(DesignSystem.Opacity.disabled))
                }
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Main Tab View") {
    MainTabView(
        repository: PreviewHomeRepository(),
        searchRepository: PreviewSearchRepository()
    )
    .preferredColorScheme(.dark)
}
#Preview("Main Tab View - Search") {
    MainTabView(
        initialTab: .search,
        repository: PreviewHomeRepository(),
        searchRepository: PreviewSearchRepository()
    )
    .preferredColorScheme(.dark)
}
#endif
