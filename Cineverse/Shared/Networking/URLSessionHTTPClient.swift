//
//  URLSessionHTTPClient.swift
//  Cineverse
//

import Foundation

final class URLSessionHTTPClient: HTTPClient, Sendable {
    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<Response: Decodable>(_ request: APIRequest<Response>) async throws -> Response {
        let urlRequest = try makeURLRequest(for: request)
        let data = try await perform(urlRequest)

        do {
            return try request.decoder.decode(Response.self, from: data)
        } catch {
            throw TMDBNetworkingError.decoding
        }
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw TMDBNetworkingError.network
            }
            return data
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as TMDBNetworkingError {
            throw error
        } catch {
            throw TMDBNetworkingError.network
        }
    }

    private func makeURLRequest<Response>(for request: APIRequest<Response>) throws -> URLRequest {
        var urlComponents = URLComponents(
            url: baseURL,
            resolvingAgainstBaseURL: false
        )

        let basePath = baseURL.path.hasSuffix("/") ? String(baseURL.path.dropLast()) : baseURL.path
        let requestPath = request.path.hasPrefix("/") ? request.path : "/\(request.path)"
        urlComponents?.path = basePath + requestPath

        if !request.queryItems.isEmpty {
            urlComponents?.queryItems = request.queryItems
        }

        guard let url = urlComponents?.url else {
            throw TMDBNetworkingError.network
        }

        var urlRequest = URLRequest(
            url: url,
            cachePolicy: request.cachePolicy,
            timeoutInterval: 60
        )
        urlRequest.httpMethod = request.method.rawValue

        for (header, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: header)
        }

        return urlRequest
    }
}
