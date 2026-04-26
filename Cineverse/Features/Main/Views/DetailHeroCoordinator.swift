//
//  DetailHeroCoordinator.swift
//  Cineverse
//

struct DetailHeroCoordinator {
    enum Phase: Equatable {
        case idle
        case openingHero
        case detailVisible
        case closingHero
    }

    private(set) var phase: Phase = .idle
    private(set) var activeRoute: DetailRoute?
    private(set) var showsDetailPoster = true
    private var managedTransitionSourceID: String?
    private var isTransitionSourceHidden = false

    var hiddenTransitionSourceID: String? {
        guard isTransitionSourceHidden else {
            return nil
        }

        return managedTransitionSourceID
    }

    var isDetailPresented: Bool {
        phase != .idle
    }

    mutating func beginOpen(route: DetailRoute, useHero: Bool) -> Bool {
        guard phase == .idle else {
            return false
        }

        activeRoute = route
        if useHero, let transitionSourceID = route.transitionSourceID {
            phase = .openingHero
            managedTransitionSourceID = transitionSourceID
            isTransitionSourceHidden = true
            showsDetailPoster = false
        } else {
            phase = .detailVisible
            managedTransitionSourceID = nil
            isTransitionSourceHidden = false
            showsDetailPoster = true
        }

        return true
    }

    mutating func completeOpenHero() {
        guard phase == .openingHero else {
            return
        }

        phase = .detailVisible
        showsDetailPoster = true
    }

    mutating func beginClose(useHero: Bool) -> Bool {
        guard activeRoute != nil, phase == .detailVisible else {
            return false
        }

        if useHero {
            phase = .closingHero
            showsDetailPoster = true
            if managedTransitionSourceID == nil {
                managedTransitionSourceID = activeRoute?.transitionSourceID
            }
            isTransitionSourceHidden = managedTransitionSourceID != nil
        } else {
            reset()
        }

        return true
    }

    mutating func handoffClosingHeroToOverlay() {
        guard phase == .closingHero else {
            return
        }

        showsDetailPoster = false
    }

    mutating func completeCloseHero() {
        guard phase == .closingHero else {
            return
        }

        reset()
    }

    mutating func beginInteractiveDismiss() {
        guard phase == .detailVisible, managedTransitionSourceID != nil else {
            return
        }

        isTransitionSourceHidden = false
    }

    mutating func cancelInteractiveDismiss() {
        guard phase == .detailVisible, managedTransitionSourceID != nil else {
            return
        }

        isTransitionSourceHidden = true
    }

    mutating func reset() {
        phase = .idle
        activeRoute = nil
        managedTransitionSourceID = nil
        isTransitionSourceHidden = false
        showsDetailPoster = true
    }
}
