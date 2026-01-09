//
//  Movie+Mocks.swift
//  Cineverse
//

#if DEBUG
import Foundation

extension Movie {
    /// Ant-Man and the Wasp: Quantumania
    static let mock = Movie(
        id: 640146,
        adult: false,
        backdropPath: "/gMJngTNfaqCSCqGD4y8lVMZXKDn.jpg",
        genreIds: [28, 12, 878],
        originalLanguage: "en",
        originalTitle: "Ant-Man and the Wasp: Quantumania",
        overview: """
        Super-Hero partners Scott Lang and Hope van Dyne, along with with Hope's parents Janet van Dyne and \
        Hank Pym, and Scott's daughter Cassie Lang, find themselves exploring the Quantum Realm, interacting \
        with strange new creatures and embarking on an adventure that will push them beyond the limits of what \
        they thought possible.
        """,
        popularity: 8567.865,
        posterPath: "/ngl2FKBlU4fhbdsrtdom9LVLBXw.jpg",
        releaseDate: "2023-02-15",
        title: "Ant-Man and the Wasp: Quantumania",
        video: false,
        voteAverage: 6.5,
        voteCount: 1886
    )

    /// The Super Mario Bros. Movie
    static let mockMario = Movie(
        id: 502356,
        adult: false,
        backdropPath: "/iJQIbOPm81fPEGKt5BPuZmfnA54.jpg",
        genreIds: [16, 12, 10751, 14, 35],
        originalLanguage: "en",
        originalTitle: "The Super Mario Bros. Movie",
        overview: """
        While working underground to fix a water main, Brooklyn plumbers—and brothers—Mario and Luigi are \
        transported down a mysterious pipe and wander into a magical new world. But when the brothers are \
        separated, Mario embarks on an epic quest to find Luigi.
        """,
        popularity: 6572.614,
        posterPath: "/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg",
        releaseDate: "2023-04-05",
        title: "The Super Mario Bros. Movie",
        video: false,
        voteAverage: 7.5,
        voteCount: 1456
    )

    /// Shazam! Fury of the Gods
    static let mockShazam = Movie(
        id: 594767,
        adult: false,
        backdropPath: "/nDxJJyA5giRhXx96q1sWbOUjMBI.jpg",
        genreIds: [28, 35, 14],
        originalLanguage: "en",
        originalTitle: "Shazam! Fury of the Gods",
        overview: """
        Billy Batson and his foster siblings, who transform into superheroes by saying "Shazam!", are forced to \
        get back into action and fight the Daughters of Atlas, who they must stop from using a weapon that could \
        destroy the world.
        """,
        popularity: 4274.232,
        posterPath: "/2VK4d3mqqTc7LVZLnLPeRiPaJ71.jpg",
        releaseDate: "2023-03-15",
        title: "Shazam! Fury of the Gods",
        video: false,
        voteAverage: 6.9,
        voteCount: 1231
    )

    /// Avatar: The Way of Water
    static let mockAvatar = Movie(
        id: 76600,
        adult: false,
        backdropPath: "/ovM06PdF3M8wvKb06i4sjW3xoww.jpg",
        genreIds: [878, 12, 28],
        originalLanguage: "en",
        originalTitle: "Avatar: The Way of Water",
        overview: """
        Set more than a decade after the events of the first film, learn the story of the Sully family (Jake, \
        Neytiri, and their kids), the trouble that follows them, the lengths they go to keep each other safe, \
        the battles they fight to stay alive, and the tragedies they endure.
        """,
        popularity: 3365.913,
        posterPath: "/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg",
        releaseDate: "2022-12-14",
        title: "Avatar: The Way of Water",
        video: false,
        voteAverage: 7.7,
        voteCount: 7535
    )

    static let mockWithoutPoster = Movie(
        id: 1,
        adult: false,
        backdropPath: nil,
        genreIds: [],
        originalLanguage: "en",
        originalTitle: "No Poster Movie",
        overview: "A movie without poster or backdrop for testing edge cases",
        popularity: 100.0,
        posterPath: nil,
        releaseDate: "2025-12-17",
        title: "No Poster Movie",
        video: false,
        voteAverage: 0.0,
        voteCount: 0
    )

    static let mockArray = [
        Movie.mock,
        Movie.mockMario,
        Movie.mockShazam,
        Movie.mockAvatar,
        Movie.mockWithoutPoster
    ]
}
#endif
