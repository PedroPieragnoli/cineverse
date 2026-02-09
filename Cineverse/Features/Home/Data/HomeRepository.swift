//
//  HomeRepository.swift
//  Cineverse
//

import Foundation

protocol HomeRepository {
    func fetchHomePayload() async throws -> HomePayload
}
