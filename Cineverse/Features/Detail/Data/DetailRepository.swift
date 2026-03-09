//
//  DetailRepository.swift
//  Cineverse
//

import Foundation

protocol DetailRepository: Sendable {
    func fetchDetail(movieID: Int) async throws -> MovieDetailPayload
}
