import AppHttpKit
import Foundation
import Testing
@testable import MovieDBData

struct CachingClientTests {
    @Test
    func test_getRequest_whenCached_shouldReturnCachedAndSkipClient() async throws {
        let cache = ResponseCache(directoryName: UUID().uuidString)
        let mockClient = CachingClientMock()
        let policy = FixedTTLPolicy(ttl: 60)
        let sut = CachingClient(
            baseURL: "https://example.com",
            client: mockClient,
            cache: cache,
            policy: policy
        )

        let request = Request(method: .get, url: "movie/popular")
        mockClient.response = Response(
            request: request,
            headers: ["Cache": "first"],
            code: 200,
            body: Data("first".utf8)
        )

        let first = try await sut.request(request)
        #expect(first.body == Data("first".utf8))
        #expect(mockClient.calls.count == 1)

        mockClient.response = Response(
            request: request,
            headers: ["Cache": "second"],
            code: 200,
            body: Data("second".utf8)
        )

        let second = try await sut.request(request)
        #expect(second.body == Data("first".utf8))
        #expect(mockClient.calls.count == 1)
    }

    @Test
    func test_getRequest_whenExpired_shouldFetchAgain() async throws {
        let cache = ResponseCache(directoryName: UUID().uuidString)
        let mockClient = CachingClientMock()
        let policy = FixedTTLPolicy(ttl: 0.01)
        let sut = CachingClient(
            baseURL: "https://example.com",
            client: mockClient,
            cache: cache,
            policy: policy
        )

        let request = Request(method: .get, url: "movie/popular")
        mockClient.response = Response(
            request: request,
            headers: [:],
            code: 200,
            body: Data("first".utf8)
        )

        _ = try await sut.request(request)
        try await Task.sleep(for: .milliseconds(30))

        mockClient.response = Response(
            request: request,
            headers: [:],
            code: 200,
            body: Data("second".utf8)
        )

        let second = try await sut.request(request)
        #expect(second.body == Data("second".utf8))
        #expect(mockClient.calls.count == 2)
    }

    @Test
    func test_nonGetRequest_shouldBypassCache() async throws {
        let cache = ResponseCache(directoryName: UUID().uuidString)
        let mockClient = CachingClientMock()
        let policy = FixedTTLPolicy(ttl: 60)
        let sut = CachingClient(
            baseURL: "https://example.com",
            client: mockClient,
            cache: cache,
            policy: policy
        )

        let request = Request(method: .post, url: "movie/popular")
        mockClient.response = Response(
            request: request,
            headers: [:],
            code: 200,
            body: Data("first".utf8)
        )

        _ = try await sut.request(request)
        mockClient.response = Response(
            request: request,
            headers: [:],
            code: 200,
            body: Data("second".utf8)
        )
        let second = try await sut.request(request)

        #expect(second.body == Data("second".utf8))
        #expect(mockClient.calls.count == 2)
    }
}

private final class CachingClientMock: Client {
    var calls: [Request] = []
    var response: Response?
    var error: Error?

    func request(_ httpRequest: Request) async throws -> Response {
        calls.append(httpRequest)
        if let error { throw error }
        guard let response else {
            fatalError("MockClient.response must be set before calling request.")
        }
        return response
    }
}

private struct FixedTTLPolicy: CachePolicy {
    let ttl: TimeInterval

    func ttl(for request: Request) -> TimeInterval? {
        ttl
    }
}
