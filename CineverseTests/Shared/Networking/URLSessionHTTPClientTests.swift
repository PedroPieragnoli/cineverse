//
//  URLSessionHTTPClientTests.swift
//  CineverseTests
//

import Foundation
import Testing
@testable import Cineverse

@Suite(.serialized)
struct URLSessionHTTPClientTests {
    private struct SampleResponse: Decodable, Equatable {
        let id: Int
        let title: String
    }

    @Test("HTTP client decodes successful response")
    func decodesSuccessfulResponse() async throws {
        let session = makeSession()
        let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, session: session)

        HTTPClientMockURLProtocol.handler = { request in
            let data = "{\"id\":1,\"title\":\"Avatar\"}".data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let request = APIRequest<SampleResponse>(method: .get, path: "/movie/1")
        let response = try await client.send(request)

        #expect(response == SampleResponse(id: 1, title: "Avatar"))
    }

    @Test("HTTP client maps non-2xx status to network error")
    func mapsNon2xxToNetworkError() async {
        let session = makeSession()
        let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, session: session)

        HTTPClientMockURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        let request = APIRequest<SampleResponse>(method: .get, path: "/movie/1")

        await #expect(throws: TMDBNetworkingError.network) {
            _ = try await client.send(request)
        }
    }

    @Test("HTTP client maps invalid payload to decoding error")
    func mapsInvalidPayloadToDecodingError() async {
        let session = makeSession()
        let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, session: session)

        HTTPClientMockURLProtocol.handler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{\"bad\":\"payload\"}".utf8))
        }

        let request = APIRequest<SampleResponse>(method: .get, path: "/movie/1")

        await #expect(throws: TMDBNetworkingError.decoding) {
            _ = try await client.send(request)
        }
    }

    @Test("HTTP client applies cache policy to URLRequest")
    func appliesCachePolicy() async throws {
        let session = makeSession()
        let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, session: session)

        HTTPClientMockURLProtocol.handler = { request in
            #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)

            let data = "{\"id\":1,\"title\":\"Avatar\"}".data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let request = APIRequest<SampleResponse>(
            method: .get,
            path: "/movie/1",
            cachePolicy: .reloadIgnoringLocalCacheData
        )

        _ = try await client.send(request)
    }

    @Test("HTTP client builds URL correctly when base URL ends with slash")
    func normalizesDoubleSlashInPath() async throws {
        let session = makeSession()
        let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.themoviedb.org/3/")!, session: session)

        HTTPClientMockURLProtocol.handler = { request in
            #expect(request.url?.absoluteString == "https://api.themoviedb.org/3/movie/1")

            let data = "{\"id\":1,\"title\":\"Avatar\"}".data(using: .utf8)!
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, data)
        }

        let request = APIRequest<SampleResponse>(method: .get, path: "/movie/1")
        _ = try await client.send(request)
    }

    @Test("HTTP client preserves cancellation errors")
    func preservesCancellationErrors() async {
        let session = makeSession()
        let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.themoviedb.org/3")!, session: session)

        HTTPClientMockURLProtocol.handler = { _ in
            throw URLError(.cancelled)
        }

        let request = APIRequest<SampleResponse>(method: .get, path: "/movie/1")

        await #expect(throws: CancellationError.self) {
            _ = try await client.send(request)
        }
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [HTTPClientMockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}

private final class HTTPClientMockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
