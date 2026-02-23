//
//  HTTPClientSpy.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

final class HTTPClientSpy: HTTPClient, @unchecked Sendable {
    struct CapturedRequest {
        let method: HTTPMethod
        let path: String
        let queryItems: [URLQueryItem]
        let headers: [String: String]
    }

    var capturedRequests: [CapturedRequest] = []
    var responseDataByPath: [String: Data] = [:]
    var errorByPath: [String: Error] = [:]

    func send<Response: Decodable>(_ request: APIRequest<Response>) async throws -> Response {
        capturedRequests.append(
            CapturedRequest(
                method: request.method,
                path: request.path,
                queryItems: request.queryItems,
                headers: request.headers
            )
        )

        if let error = errorByPath[request.path] {
            throw error
        }

        let data = try #require(
            responseDataByPath[request.path],
            "Expected stub response for path \(request.path)"
        )

        return try request.decoder.decode(Response.self, from: data)
    }
}

func encode<T: Encodable>(_ value: T) -> Data {
    let encoder = JSONEncoder()
    return (try? encoder.encode(value)) ?? Data()
}
