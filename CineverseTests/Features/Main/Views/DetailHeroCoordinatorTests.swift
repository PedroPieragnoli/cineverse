//
//  DetailHeroCoordinatorTests.swift
//  CineverseTests
//

import CoreGraphics
import Testing
@testable import Cineverse

struct DetailHeroCoordinatorTests {
    @Test("beginOpen with hero enters opening phase and hides source poster")
    func beginOpenHero() {
        var coordinator = DetailHeroCoordinator()
        let route = posterRoute()

        let started = coordinator.beginOpen(route: route, useHero: true)

        #expect(started)
        #expect(coordinator.phase == .openingHero)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == route.transitionSourceID)
        #expect(coordinator.showsDetailPoster == false)
    }

    @Test("open hero completion shows detail poster and keeps source hidden")
    func completeOpenHero() {
        let coordinator = openedCoordinator(route: posterRoute(), useHero: true)

        #expect(coordinator.phase == .detailVisible)
        #expect(coordinator.activeRoute == posterRoute())
        #expect(coordinator.hiddenTransitionSourceID == posterRoute().transitionSourceID)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("beginOpen with hero requested but no transition source skips opening phase")
    func beginOpenWithHeroRequestedButNoTransitionSourceSkipsOpeningPhase() {
        var coordinator = DetailHeroCoordinator()
        let route = heroRoute()

        let started = coordinator.beginOpen(route: route, useHero: true)

        #expect(started)
        #expect(coordinator.phase == .detailVisible)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == nil)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("beginClose with hero enters closing phase and hides detail poster")
    func beginCloseHero() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        let route = posterRoute()

        let startedClose = coordinator.beginClose(useHero: true)

        #expect(startedClose)
        #expect(coordinator.phase == .closingHero)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == route.transitionSourceID)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("closing hero handoff hides detail poster only after overlay is ready")
    func closingHeroHandoffHidesDetailPoster() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        let route = posterRoute()
        _ = coordinator.beginClose(useHero: true)

        #expect(coordinator.showsDetailPoster)

        coordinator.handoffClosingHeroToOverlay()

        #expect(coordinator.phase == .closingHero)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == route.transitionSourceID)
        #expect(coordinator.showsDetailPoster == false)
    }

    @Test("closing hero completion resets coordinator and unhides source")
    func completeCloseHero() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        _ = coordinator.beginClose(useHero: true)
        coordinator.completeCloseHero()

        #expect(coordinator.phase == .idle)
        #expect(coordinator.activeRoute == nil)
        #expect(coordinator.hiddenTransitionSourceID == nil)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("interactive dismiss begin releases the hidden source poster")
    func beginInteractiveDismissReleasesHiddenSourcePoster() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        let route = posterRoute()

        coordinator.beginInteractiveDismiss()

        #expect(coordinator.phase == .detailVisible)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == nil)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("interactive dismiss cancel restores the hidden source poster")
    func cancelInteractiveDismissRestoresHiddenSourcePoster() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        let route = posterRoute()
        coordinator.beginInteractiveDismiss()

        coordinator.cancelInteractiveDismiss()

        #expect(coordinator.phase == .detailVisible)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == route.transitionSourceID)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("close without hero after interactive dismiss resets coordinator")
    func closeWithoutHeroAfterInteractiveDismissResetsCoordinator() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        let route = posterRoute()
        coordinator.beginInteractiveDismiss()

        #expect(coordinator.phase == .detailVisible)
        #expect(coordinator.activeRoute == route)
        #expect(coordinator.hiddenTransitionSourceID == nil)
        #expect(coordinator.showsDetailPoster)

        let startedClose = coordinator.beginClose(useHero: false)

        #expect(startedClose)
        #expect(coordinator.phase == .idle)
        #expect(coordinator.activeRoute == nil)
        #expect(coordinator.hiddenTransitionSourceID == nil)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("beginClose without hero resets immediately")
    func beginCloseWithoutHeroResetsImmediately() {
        var coordinator = DetailHeroCoordinator()

        _ = coordinator.beginOpen(route: heroRoute(), useHero: false)
        let startedClose = coordinator.beginClose(useHero: false)

        #expect(startedClose)
        #expect(coordinator.phase == .idle)
        #expect(coordinator.activeRoute == nil)
        #expect(coordinator.hiddenTransitionSourceID == nil)
        #expect(coordinator.showsDetailPoster)
    }

    @Test("beginOpen rejects re-entry while detail is already presented")
    func beginOpenRejectsReentry() {
        var coordinator = DetailHeroCoordinator()

        let firstOpen = coordinator.beginOpen(route: posterRoute(), useHero: true)
        let secondOpen = coordinator.beginOpen(route: posterRoute(), useHero: true)

        #expect(firstOpen)
        #expect(secondOpen == false)
    }

    @Test("beginOpen rejects re-entry while closing hero overlay is in flight")
    func beginOpenRejectsWhileClosingHeroOverlayInFlight() {
        var coordinator = openedCoordinator(route: posterRoute(), useHero: true)
        _ = coordinator.beginClose(useHero: true)
        coordinator.handoffClosingHeroToOverlay()

        let secondOpen = coordinator.beginOpen(route: posterRoute(), useHero: true)

        #expect(secondOpen == false)
        #expect(coordinator.phase == .closingHero)
    }

    @Test(
        "guarded mutations from incompatible states leave coordinator unchanged",
        arguments: GuardCase.allCases
    )
    func guardedMutationsLeaveCoordinatorUnchanged(guardCase: GuardCase) {
        var coordinator = guardCase.makeCoordinator(
            posterRoute: posterRoute(),
            heroRoute: heroRoute()
        )
        let expectedPhase = coordinator.phase
        let expectedActiveRoute = coordinator.activeRoute
        let expectedHiddenTransitionSourceID = coordinator.hiddenTransitionSourceID
        let expectedShowsDetailPoster = coordinator.showsDetailPoster

        guardCase.invoke(on: &coordinator)

        #expect(coordinator.phase == expectedPhase)
        #expect(coordinator.activeRoute == expectedActiveRoute)
        #expect(coordinator.hiddenTransitionSourceID == expectedHiddenTransitionSourceID)
        #expect(coordinator.showsDetailPoster == expectedShowsDetailPoster)
    }

    @Test("isDetailPresented is false when idle and true across active phases")
    func isDetailPresentedReflectsActivePhases() {
        var coordinator = DetailHeroCoordinator()

        #expect(coordinator.phase == .idle)
        #expect(coordinator.isDetailPresented == false)

        _ = coordinator.beginOpen(route: posterRoute(), useHero: true)
        #expect(coordinator.phase == .openingHero)
        #expect(coordinator.isDetailPresented)

        coordinator.completeOpenHero()
        #expect(coordinator.phase == .detailVisible)
        #expect(coordinator.isDetailPresented)

        _ = coordinator.beginClose(useHero: true)
        #expect(coordinator.phase == .closingHero)
        #expect(coordinator.isDetailPresented)
    }

    private func posterRoute() -> DetailRoute {
        DetailRoute(
            movie: .mock,
            source: .posterCard,
            sourcePosterFrame: CGRect(x: 20, y: 220, width: 120, height: 180)
        )
    }

    private func heroRoute() -> DetailRoute {
        DetailRoute(movie: .mock, source: .hero)
    }

    private func openedCoordinator(route: DetailRoute, useHero: Bool) -> DetailHeroCoordinator {
        var coordinator = DetailHeroCoordinator()
        _ = coordinator.beginOpen(route: route, useHero: useHero)
        if useHero {
            coordinator.completeOpenHero()
        }
        return coordinator
    }
}

extension DetailHeroCoordinatorTests {
    enum GuardCase: CaseIterable {
        case completeOpenHeroFromIdle
        case completeOpenHeroFromDetailVisible
        case handoffClosingHeroFromIdle
        case handoffClosingHeroFromDetailVisible
        case completeCloseHeroFromIdle
        case cancelInteractiveDismissWithoutBegin
        case beginInteractiveDismissWithoutManagedTransitionSource

        func makeCoordinator(posterRoute: DetailRoute, heroRoute: DetailRoute) -> DetailHeroCoordinator {
            var coordinator = DetailHeroCoordinator()
            switch self {
            case .completeOpenHeroFromIdle,
                 .handoffClosingHeroFromIdle,
                 .completeCloseHeroFromIdle:
                return coordinator
            case .completeOpenHeroFromDetailVisible,
                 .handoffClosingHeroFromDetailVisible,
                 .cancelInteractiveDismissWithoutBegin:
                _ = coordinator.beginOpen(route: posterRoute, useHero: true)
                coordinator.completeOpenHero()
                return coordinator
            case .beginInteractiveDismissWithoutManagedTransitionSource:
                _ = coordinator.beginOpen(route: heroRoute, useHero: false)
                return coordinator
            }
        }

        func invoke(on coordinator: inout DetailHeroCoordinator) {
            switch self {
            case .completeOpenHeroFromIdle, .completeOpenHeroFromDetailVisible:
                coordinator.completeOpenHero()
            case .handoffClosingHeroFromIdle, .handoffClosingHeroFromDetailVisible:
                coordinator.handoffClosingHeroToOverlay()
            case .completeCloseHeroFromIdle:
                coordinator.completeCloseHero()
            case .cancelInteractiveDismissWithoutBegin:
                coordinator.cancelInteractiveDismiss()
            case .beginInteractiveDismissWithoutManagedTransitionSource:
                coordinator.beginInteractiveDismiss()
            }
        }
    }
}
