//
//  DetailView.swift
//  Cineverse
//

import SwiftUI

struct DetailView: View {
    private enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let bottomPadding: CGFloat = 48
        static let dismissInfoFadeDuration: TimeInterval = 0.24
        static let headerSeparatorScrollThreshold: CGFloat = 8
        static let scrollEdgeTolerance: CGFloat = 1
        static let swipeDismissFadeDuration: TimeInterval = 0.15
    }

    // MARK: - Properties

    let route: DetailRoute
    let topSafeAreaInset: CGFloat
    let showsHeroPoster: Bool
    let revealOpacity: CGFloat
    let entranceToken: UUID?
    let onPosterFrameChanged: ((CGRect?) -> Void)?
    let onStateChange: ((SwipeDismissState) -> Void)?
    let onCloseRequested: ((DetailDismissTransition?) -> Void)?
    let onScheduleDismissLeadIn: ((@escaping @MainActor () -> Void) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: DetailViewModel
    @State private var scrollOffset: CGFloat = 0
    @State private var isAtBottom = false
    @State private var isSwipeDismissGestureActive = false
    @State private var isRunningDismissHero = false
    @State private var dismissInfoOpacity: CGFloat = 1
    @State private var dismissBackgroundOpacity: CGFloat = 1
    @State private var detailPosterFrame: CGRect?

    init(
        route: DetailRoute,
        topSafeAreaInset: CGFloat = 0,
        showsHeroPoster: Bool = true,
        revealOpacity: CGFloat = 1,
        entranceToken: UUID? = nil,
        onPosterFrameChanged: ((CGRect?) -> Void)? = nil,
        onStateChange: ((SwipeDismissState) -> Void)? = nil,
        onCloseRequested: ((DetailDismissTransition?) -> Void)? = nil,
        onScheduleDismissLeadIn: ((@escaping @MainActor () -> Void) -> Void)? = nil,
        viewModel: DetailViewModel? = nil
    ) {
        self.route = route
        self.topSafeAreaInset = topSafeAreaInset
        self.showsHeroPoster = showsHeroPoster
        self.revealOpacity = revealOpacity
        self.entranceToken = entranceToken
        self.onPosterFrameChanged = onPosterFrameChanged
        self.onStateChange = onStateChange
        self.onCloseRequested = onCloseRequested
        self.onScheduleDismissLeadIn = onScheduleDismissLeadIn
        _viewModel = State(initialValue: viewModel ?? DetailViewModel(movie: route.movie))
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                swipeableContent(containerSize: geometry.size)
                headerSafeAreaFill
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadInitialData()
        }
        .task(id: entranceToken) {
            guard entranceToken != nil else { return }
            await viewModel.startEntranceAnimation(reduceMotion: reduceMotion)
        }
        .onChange(of: route.id) { _, _ in
            resetDismissState()
        }
        .onPreferenceChange(DetailHeroPosterFramePreferenceKey.self) { newFrame in
            detailPosterFrame = newFrame
            onPosterFrameChanged?(newFrame)
        }
        .onDisappear {
            onPosterFrameChanged?(nil)
        }
    }

    private var shouldUsePosterHeroTransition: Bool {
        DetailPosterHeroTransitionPolicy.isEnabled(
            source: route.source,
            sourcePosterFrame: route.sourcePosterFrame,
            reduceMotion: reduceMotion
        )
    }

    private var entranceAnimation: Animation {
        .interpolatingSpring(mass: 1, stiffness: 250, damping: 25, initialVelocity: 0)
    }

    private var contentTopPadding: CGFloat {
        DetailHeaderView.contentHeight + DesignSystem.Spacing.sm
    }

    private var composedRevealOpacity: CGFloat {
        revealOpacity * dismissInfoOpacity
    }

    private var headerSafeAreaFillOpacity: CGFloat {
        isSwipeDismissGestureActive ? 0 : composedRevealOpacity
    }

    // MARK: - Content

    private func swipeableContent(containerSize: CGSize) -> some View {
        ZStack(alignment: .top) {
            detailBackground
            scrollContent
            headerOverlay
        }
        .swipeToDismiss(
            isScrolledToTop: isScrollAtTop,
            isScrolledToBottom: isAtBottom,
            in: containerSize,
            reduceMotion: reduceMotion,
            onStateChange: handleSwipeDismissStateChange
        ) {
            requestClose(transition: nil)
        }
    }

    private var isScrollAtTop: Bool {
        scrollOffset <= Layout.scrollEdgeTolerance
    }

    private var detailBackground: some View {
        DesignSystem.Colors.background
            .opacity(revealOpacity * dismissBackgroundOpacity)
            .ignoresSafeArea()
    }

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            sectionsStack
                .padding(.horizontal, Layout.horizontalPadding)
                .padding(.top, contentTopPadding)
                .padding(.bottom, Layout.bottomPadding)
        }
        .scrollDisabled(isSwipeDismissGestureActive)
        .opacity(revealOpacity)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            scrollOffset = max(0, newValue)
        }
        .onScrollGeometryChange(for: Bool.self) { geometry in
            isScrollAtBottom(geometry)
        } action: { _, newValue in
            isAtBottom = newValue
        }
    }

    private var sectionsStack: some View {
        VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
            heroSection
            playButton
            synopsisSection
            castSection
        }
    }

    private var heroSection: some View {
        DetailHeroSectionView(
            poster: .init(
                posterURL: viewModel.posterURL,
                placeholderPosterURL: route.sourcePosterURL,
                showsHeroPoster: showsHeroPoster,
                shouldUsePosterHeroTransition: shouldUsePosterHeroTransition
            ),
            metadata: .init(
                title: viewModel.title,
                ratingText: viewModel.ratingText,
                yearRuntimeText: viewModel.yearRuntimeText,
                genreNames: viewModel.genreNames
            ),
            presentation: .init(
                isLoading: viewModel.isLoading,
                hasPayload: viewModel.movieDetail != nil,
                showsMetadataSection: viewModel.showsMetadataSection,
                dismissInfoOpacity: dismissInfoOpacity,
                entranceAnimation: entranceAnimation
            )
        )
    }

    private var playButton: some View {
        DetailPlayButton(
            isVisible: viewModel.showsPlayButton,
            dismissInfoOpacity: dismissInfoOpacity,
            entranceAnimation: entranceAnimation
        ) {
            // TODO: wire play action when streaming is implemented
        }
    }

    private var synopsisSection: some View {
        SynopsisSectionView(
            overview: viewModel.overview,
            isOverviewExpanded: viewModel.isOverviewExpanded,
            isVisible: viewModel.showsSecondaryContent,
            dismissInfoOpacity: dismissInfoOpacity,
            entranceAnimation: entranceAnimation
        ) {
            viewModel.toggleOverviewExpanded()
        }
    }

    private var castSection: some View {
        CastSectionView(
            cast: viewModel.cast,
            isVisible: viewModel.showsSecondaryContent,
            dismissInfoOpacity: dismissInfoOpacity,
            entranceAnimation: entranceAnimation
        )
    }

    private func isScrollAtBottom(_ geometry: ScrollGeometry) -> Bool {
        let bottomEdge = geometry.contentOffset.y + geometry.containerSize.height
        return bottomEdge >= geometry.contentSize.height - Layout.scrollEdgeTolerance
    }

    private var headerOverlay: some View {
        DetailHeaderView(
            horizontalPadding: Layout.horizontalPadding,
            isFavorite: viewModel.isFavorite,
            showsSeparator: scrollOffset > Layout.headerSeparatorScrollThreshold,
            contentOpacity: composedRevealOpacity,
            onBack: handleBackButtonTap,
            onToggleFavorite: viewModel.toggleFavorite
        )
    }

    private var headerSafeAreaFill: some View {
        DesignSystem.Colors.headerTint
            .frame(height: topSafeAreaInset)
            .ignoresSafeArea(edges: .top)
            .opacity(headerSafeAreaFillOpacity)
            .animation(
                .easeOut(duration: Layout.swipeDismissFadeDuration),
                value: isSwipeDismissGestureActive
            )
            .allowsHitTesting(false)
    }
}

private extension DetailView {
    func resetDismissState() {
        isAtBottom = false
        isSwipeDismissGestureActive = false
        isRunningDismissHero = false
        dismissInfoOpacity = 1
        dismissBackgroundOpacity = 1
    }

    func handleBackButtonTap() {
        guard shouldUsePosterHeroTransition else {
            requestClose(transition: nil)
            return
        }
        guard !isRunningDismissHero else { return }
        isRunningDismissHero = true
        startDismissLeadInFade()
        scheduleHeroClose()
    }

    func startDismissLeadInFade() {
        withAnimation(.linear(duration: Layout.dismissInfoFadeDuration)) {
            dismissInfoOpacity = 0
            dismissBackgroundOpacity = 0
        }
    }

    func scheduleHeroClose() {
        let finishDismissHeroIfStillActive: @MainActor () -> Void = {
            guard isRunningDismissHero else { return }
            requestClose(transition: dismissTransition)
        }

        if let onScheduleDismissLeadIn {
            onScheduleDismissLeadIn(finishDismissHeroIfStillActive)
        } else {
            finishDismissHeroIfStillActive()
        }
    }

    func requestClose(transition: DetailDismissTransition?) {
        if let onCloseRequested {
            onCloseRequested(transition)
        } else {
            dismiss()
        }
    }

    func handleSwipeDismissStateChange(_ state: SwipeDismissState) {
        switch state {
        case .began, .committed:
            isSwipeDismissGestureActive = true
        case .cancelled:
            isSwipeDismissGestureActive = false
        }
        onStateChange?(state)
    }

    var dismissTransition: DetailDismissTransition? {
        guard shouldUsePosterHeroTransition,
              let startFrame = detailPosterFrame,
              let endFrame = route.sourcePosterFrame else {
            return nil
        }

        return DetailDismissTransition(
            posterURL: viewModel.posterURL,
            startFrame: startFrame,
            endFrame: endFrame
        )
    }
}
