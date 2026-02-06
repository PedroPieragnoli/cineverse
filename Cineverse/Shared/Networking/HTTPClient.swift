//
//  HTTPClient.swift
//  Cineverse
//

import Foundation

protocol HTTPClient {
    func send<Response: Decodable>(_ request: APIRequest<Response>) async throws -> Response
}
