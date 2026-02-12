import AppHttpKit
import Foundation

public final class CachingClient: Client {
    private let baseURL: String
    private let client: Client
    private let cache: ResponseCache
    private let policy: CachePolicy
    private let urlBuilder: URLBuilder

    public init(
        baseURL: String,
        client: Client,
        cache: ResponseCache,
        policy: CachePolicy,
        urlBuilder: URLBuilder = HttpURLBuilder()
    ) {
        self.baseURL = baseURL
        self.client = client
        self.cache = cache
        self.policy = policy
        self.urlBuilder = urlBuilder
    }

    public func request(_ httpRequest: Request) async throws -> Response {
        guard httpRequest.method == .get, let ttl = policy.ttl(for: httpRequest), ttl > 0 else {
            return try await client.request(httpRequest)
        }

        let key = try cacheKey(for: httpRequest)
        if let cached = await cache.entry(for: key) {
            return Response(request: httpRequest, headers: cached.headers, code: cached.code, body: cached.body)
        }

        let response = try await client.request(httpRequest)
        if response.isSuccessful {
            let entry = ResponseCache.Entry(
                expiry: Date().addingTimeInterval(ttl),
                code: response.code,
                headers: response.headers,
                body: response.body
            )
            await cache.set(entry, for: key)
        }
        return response
    }

    private func cacheKey(for request: Request) throws -> String {
        let url = try urlBuilder.buildURL(baseURL: baseURL, request: request)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return url.absoluteString
        }
        if let items = components.queryItems, !items.isEmpty {
            components.queryItems = items.sorted {
                if $0.name == $1.name { return ($0.value ?? "") < ($1.value ?? "") }
                return $0.name < $1.name
            }
        }
        return components.url?.absoluteString ?? url.absoluteString
    }
}
