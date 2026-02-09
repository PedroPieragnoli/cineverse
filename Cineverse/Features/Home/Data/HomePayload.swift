//
//  HomePayload.swift
//  Cineverse
//

import Foundation

struct HomePayload {
    let featuredMovie: FeaturedMovie?
    let trendingMovies: [Movie]
    let newReleases: [Movie]
    let continueWatching: [ContinueWatchingItem]
}
