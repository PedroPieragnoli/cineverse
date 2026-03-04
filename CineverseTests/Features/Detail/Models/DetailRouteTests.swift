//
//  DetailRouteTests.swift
//  CineverseTests
//

import CoreGraphics
import Testing
@testable import Cineverse

struct DetailRouteTests {
    @Test("Detail route identity is stable regardless of source poster frame")
    func identityIgnoresSourcePosterFrame() {
        let routeA = DetailRoute(
            movie: .mock,
            source: .posterCard,
            sourcePosterFrame: CGRect(x: 10, y: 20, width: 120, height: 180)
        )
        let routeB = DetailRoute(
            movie: .mock,
            source: .posterCard,
            sourcePosterFrame: CGRect(x: 50, y: 100, width: 100, height: 150)
        )

        #expect(routeA.id == routeB.id)
        #expect(routeA == routeB)
        #expect(Set([routeA, routeB]).count == 1)
    }

    @Test("Detail route identity includes source")
    func identityIncludesSource() {
        let posterRoute = DetailRoute(movie: .mock, source: .posterCard)
        let heroRoute = DetailRoute(movie: .mock, source: .hero)

        #expect(posterRoute.id != heroRoute.id)
        #expect(posterRoute != heroRoute)
    }

    @Test("Detail route identity differs across movies with the same source")
    func identityDiffersAcrossMovies() {
        let routeA = DetailRoute(movie: .mock, source: .posterCard)
        let routeB = DetailRoute(movie: .mockMario, source: .posterCard)

        #expect(routeA.id != routeB.id)
        #expect(routeA != routeB)
    }

    @Test("Detail route id combines movie id and source key")
    func idCombinesMovieIDAndSourceKey() {
        let route = DetailRoute(movie: .mock, source: .posterCard)

        #expect(route.id == "\(Movie.mock.id)-poster")
    }

    @Test("Detail route transition source uses explicit source transition id when provided")
    func transitionSourceUsesExplicitID() {
        let route = DetailRoute(
            movie: .mock,
            source: .posterCard,
            customTransitionSourceID: "custom-explicit-id"
        )

        #expect(route.transitionSourceID == "custom-explicit-id")
    }

    @Test("Detail route transition source falls back to movie id when no custom id is provided")
    func transitionSourceFallsBackToMovieID() {
        let route = DetailRoute(movie: .mock, source: .posterCard)

        #expect(route.transitionSourceID == "movie-poster-\(Movie.mock.id)")
    }

    @Test("Detail route transition source is nil for hero source")
    func transitionSourceIsNilForHeroSource() {
        let route = DetailRoute(
            movie: .mock,
            source: .hero,
            customTransitionSourceID: "custom-explicit-id"
        )

        #expect(route.transitionSourceID == nil)
    }
}
