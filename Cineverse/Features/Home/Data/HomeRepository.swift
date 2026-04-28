//
//  HomeRepository.swift
//  Cineverse
//

import Foundation

protocol HomeRepository: Sendable {
    func fetchHomePayload() async throws -> HomePayload
}
